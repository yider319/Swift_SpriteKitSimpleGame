//
//  GameScene.swift
//  Sprite
//
//  Created by Yi-Der Lin on 6/29/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}



import SpriteKit


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}


struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Bunny     : UInt32 = 0b11      // 3
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    // 1
    let player = SKSpriteNode(imageNamed: "gorilla")
    var bunnyhitted = 0
    
    override func didMoveToView(view: SKView) {
        //playBackgroundMusic("background-music-aac.caf")
        playBackgroundMusic("cautious-path.mp3")
        
        // 2
        backgroundColor = SKColor.whiteColor()
        // 3
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // 4
        addChild(player)
        
        physicsWorld.gravity = CGVectorMake(0,0)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(3.0)
                ])
            ))
    }
    
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create carrot sprite
        let monster = SKSpriteNode(imageNamed: "carrot")
        monster.size = CGSize(width: 80, height: 60)
        
        // Create Boss Bunny sprite
        let bunny = SKSpriteNode(imageNamed: "Bugs_Bunny")
        bunny.size = CGSize(width: 70, height: 100)
        
        // give physics body to carrot
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,20))
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // will test with Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // no default collision
        
        // give physics body to Boss Bunny
        bunny.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,60))
        bunny.physicsBody?.dynamic = true
        bunny.physicsBody?.categoryBitMask = PhysicsCategory.Bunny
        bunny.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // will test with Projectile
        bunny.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - bunny.size.height/2)
        //let actualY = CGFloat(100)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width - monster.size.width, y: actualY)
        bunny.position = CGPoint(x: size.width - bunny.size.width/2, y: actualY)
        
        
        // Add the monster to the scene
        addChild(monster)
        addChild(bunny)
        
        // Determine speed of the carrot
        let actualDuration = random(min: CGFloat(4.5), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        // If the carrot reaches to the destination successfully -> Game Over
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        // show the bunny
        let newdes = bunny.position
        let actionPresent = SKAction.moveTo(newdes, duration: 2.0) // if duration>3, bunny collides with bunny -> Problem of collision prediction algorithm?
        bunny.runAction(SKAction.sequence([actionPresent, actionMoveDone]))
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Sound of throwing banana
        runAction(SKAction.playSoundFileNamed("throw_sound.mp3", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "banana")
        
        projectile.size = CGSize(width: 40, height: 30)
        
        projectile.position = player.position + CGPoint(x: 34, y: 40)
        
        // give physics body to banana
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster | PhysicsCategory.Bunny // banana will check collision with either carrot or Boss Bunny
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true

        
        // Determine rotational speed of the projectile
        let actualRot = random(min: CGFloat(-50.0), max: CGFloat(-1.0))
        let action = SKAction.rotateByAngle(actualRot, duration:1)
        
        projectile.runAction(SKAction.repeatActionForever(action))
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        //        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        // Sound of banana hitting with carrot
        runAction(SKAction.playSoundFileNamed("Squish.mp3", waitForCompletion: false))
        
        println("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        // picture of explision
        let boom = SKSpriteNode(imageNamed: "boom")
        
        // rescale the boom
        boom.size = CGSize(width: 80, height: 80)
        
        boom.position = projectile.position
        
        addChild(boom)
        
        
        // make the explision move a little bit for vivid dynamics
        let shiftX = random(min: monster.size.width/2, max: monster.size.width)
        var shiftY = CGFloat(0.0)
        
        if (monster.position.y > CGFloat(187.5) ) {
            
            shiftY = random(min: monster.size.height/2, max: monster.size.height)
            
        } else {
            
            shiftY = random(min: -monster.size.height, max: -monster.size.height/2)
            
        }
        
        let newdes = boom.position + CGPoint(x: shiftX, y: shiftY)
        let actionMove = SKAction.moveTo(newdes, duration: 0.2)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        boom.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    
    func projectileDidCollideWithBunny(bunny:SKSpriteNode, projectile:SKSpriteNode) {
        // Sound of banana hitting Boss Bunny
        runAction(SKAction.playSoundFileNamed("Pain_Sound.mp3", waitForCompletion: false))
        
        
        println("Hit Bunny")
        projectile.removeFromParent()
        bunny.removeFromParent()
        
        // Load picture of Bunny got hitted
        let shocked_bunny = SKSpriteNode(imageNamed: "shocked_bunny")
        
        // rescale the picture
        shocked_bunny.size = CGSize(width: 80, height: 80)
        
        shocked_bunny.position = bunny.position
        
        addChild(shocked_bunny)
        
        
        let newdes = shocked_bunny.position
        let actionMove = SKAction.moveTo(newdes, duration: 0.6)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        shocked_bunny.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        
        // Hit 2 times to win
        bunnyhitted++
        if (bunnyhitted > 1) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }

    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // sort out the index of collision bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // debug to see the index
        println(firstBody.categoryBitMask)
        println(secondBody.categoryBitMask)
        
        // if banana hits carrot
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
        // if banana hits Boss Bunny
        if ((firstBody.categoryBitMask & PhysicsCategory.Projectile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bunny != 0)) {
                projectileDidCollideWithBunny(firstBody.node as! SKSpriteNode, projectile: secondBody.node as! SKSpriteNode)
        }
        
    }
    
}
