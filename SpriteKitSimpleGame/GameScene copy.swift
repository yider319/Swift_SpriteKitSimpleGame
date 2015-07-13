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
    static let Bullet   : UInt32 = 0b00001
    static let Carrot   : UInt32 = 0b00010
    static let Bunny     : UInt32 = 0b00011
    static let Gorilla     : UInt32 = 0b00100
    static let Rhino_back     : UInt32 = 0b00101
    static let Rhino_front     : UInt32 = 0b00110
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    // 1
    let playerheart_1 = SKSpriteNode(imageNamed: "heart")
    let playerheart_2 = SKSpriteNode(imageNamed: "heart")
    let playerheart_3 = SKSpriteNode(imageNamed: "heart")
    
    var playerlife = 3
    var rhinolife = 2

    
    override func didMoveToView(view: SKView) {
        //playBackgroundMusic("background-music-aac.caf")
        playBackgroundMusic("cautious-path.mp3")
        
        // 2
        backgroundColor = SKColor.whiteColor()
        // 3
        playerheart_1.position = CGPoint(x: size.width * 0.86, y: size.height * 0.94)
        playerheart_1.size = CGSize(width: 30, height: 30)
        playerheart_2.position = CGPoint(x: size.width * 0.90, y: size.height * 0.94)
        playerheart_2.size = CGSize(width: 30, height: 30)
        playerheart_3.position = CGPoint(x: size.width * 0.94, y: size.height * 0.94)
        playerheart_3.size = CGSize(width: 30, height: 30)
        // 4
        addChild(playerheart_1)
        addChild(playerheart_2)
        addChild(playerheart_3)
        
        physicsWorld.gravity = CGVectorMake(0,0)
        physicsWorld.contactDelegate = self


        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster1),
                SKAction.runBlock(addMonster2),
                SKAction.waitForDuration(3.0)
                ])
            ))


        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster3),
                SKAction.waitForDuration(5.0)
                ])
            ))

    }
    
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
/////
    // rescale the physics body part 1
    func offset(node: SKSpriteNode, isX: Bool)->CGFloat {
        return isX ? node.frame.size.width * node.anchorPoint.x : node.frame.size.height * node.anchorPoint.y
    }
    
    // rescale the physics body part 2
    func AddLineToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathAddLineToPoint(path, nil, (x * 1/2.2) - offset(node, isX: true), (y * 1/2.2) - offset(node, isX: false))
    }
    
    // rescale the physics body part 3
    func MoveToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathMoveToPoint(path, nil, (x * 1/2.2) - offset(node, isX: true), (y * 1/2.2) - offset(node, isX: false))
    }
/////
    
    
    func addMonster1() {
        
        // Create Boss Bunny sprite
        let bunny = SKSpriteNode(imageNamed: "Bugs_Bunny")
        bunny.size = CGSize(width: 70, height: 100)
        
        // Create attack from Boss Bunny sprite
        let carrot = SKSpriteNode(imageNamed: "carrot")
        carrot.size = CGSize(width: 30, height: 50)
        
        // give physics body to Boss Bunny
        //bunny.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,60))
        let offsetX = bunny.frame.size.width * bunny.anchorPoint.x
        let offsetY = bunny.frame.size.height * bunny.anchorPoint.y
        
        
        let path = CGPathCreateMutable()
        MoveToPoint(path,  x: 44, y: 106, node: bunny)
        AddLineToPoint(path,  x: 54, y: 202, node: bunny)
        AddLineToPoint(path,  x: 86, y: 212, node: bunny)
        AddLineToPoint(path,  x: 121, y: 124, node: bunny)
        CGPathCloseSubpath(path)
        bunny.physicsBody = SKPhysicsBody(polygonFromPath: path)

        //
        bunny.physicsBody?.dynamic = true
        bunny.physicsBody?.categoryBitMask = PhysicsCategory.Bunny
        bunny.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        bunny.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the Bunny along the Y axis
//        let actualY = random(min: bunny.size.height/2, max: size.height - bunny.size.height/2)
        let actualY = CGFloat(100)
        
        // Position the bunny slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        // bunny.position = CGPoint(x: size.width - bunny.size.width/2, y: actualY)
        bunny.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        // Add the carrot to the scene
        carrot.position = bunny.position
        
        // give physicsbody to carrot
        carrot.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,60))
        carrot.physicsBody?.dynamic = true
        carrot.physicsBody?.categoryBitMask = PhysicsCategory.Carrot
        carrot.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        carrot.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        addChild(bunny)
        addChild(carrot)
        
        // Determine speed of the carrot
        var actualZoom = random(min: CGFloat(4.5), max: CGFloat(6.0))
        let actionAttack = SKAction.scaleTo(actualZoom, duration: 3)
        
        // Determine rotational speed of the carrot
        let actualRot = random(min: CGFloat(-5.0), max: CGFloat(5.0))
        let actionWeaponRot = SKAction.rotateByAngle(actualRot, duration:1)
        carrot.runAction(SKAction.repeatActionForever(actionWeaponRot))
        
        
        // Create the actions
//        let actionMove = SKAction.moveTo(CGPoint(x: -bunny.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        // If the carrot reaches to the destination successfully -> Game Over
//        let loseAction = SKAction.runBlock() {
//            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
        
//        carrot.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))

        // player life reduced
        let loseHeart = SKAction.runBlock() {
            self.playerlife--
            
            if (self.playerlife == 2) {
                self.playerheart_3.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 1) {
                self.playerheart_2.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 0) {
                self.playerheart_1.runAction(actionMoveDone)
            }
        }
        
        
        // player got hit screen
        let loseHeartAnimation = SKAction.runBlock() {
            self.player_hit(carrot)
            
        }
        
        // show the bunny
        let newdes = bunny.position
        let actionPresent = SKAction.moveTo(newdes, duration: 3.0) // if duration>3, bunny collides with bunny -> Problem of collision prediction algorithm?
        bunny.runAction(SKAction.sequence([actionPresent, actionMoveDone]))
        
        carrot.runAction(SKAction.sequence([actionAttack, loseHeart , loseHeartAnimation, actionMoveDone]))
    }
    
    
    func addMonster2() {
        
        // Create Gorilla sprite
        let gorilla = SKSpriteNode(imageNamed: "gorilla")
        gorilla.size = CGSize(width: 80, height: 80)
        
        // Create attack from Gorilla sprite
        let banana = SKSpriteNode(imageNamed: "banana")
        banana.size = CGSize(width: 20, height: 20)
        
        // give physics body to Gorilla
        gorilla.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(60,60))
        gorilla.physicsBody?.dynamic = true
        gorilla.physicsBody?.categoryBitMask = PhysicsCategory.Bunny
        gorilla.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        gorilla.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the Gorilla along the Y axis
        //        let actualY = random(min: bunny.size.height/2, max: size.height - bunny.size.height/2)
        let actualY = CGFloat(200)
        
        // Position the bunny slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        gorilla.position = CGPoint(x: size.width/4, y: actualY)
        //gorilla.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        // Add the banana to the scene
        banana.position = gorilla.position
        
        // give physicsbody to carrot
        banana.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(15,20))
        banana.physicsBody?.dynamic = true
        banana.physicsBody?.categoryBitMask = PhysicsCategory.Carrot
        banana.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        banana.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        addChild(gorilla)
        addChild(banana)
        
        // Determine speed of the banana
        var actualZoom = random(min: CGFloat(4.5), max: CGFloat(6.0))
        let actionAttack = SKAction.scaleTo(actualZoom, duration: 3)
        
        // Determine rotational speed of the banana
        let actualRot = random(min: CGFloat(7.0), max: CGFloat(15.0))
        let actionWeaponRot = SKAction.rotateByAngle(actualRot, duration:1)
        banana.runAction(SKAction.repeatActionForever(actionWeaponRot))
        
        // Determine curve of the banana
        let shiftY = random(min: CGFloat(80.0), max: CGFloat(100.0)) + gorilla.position.y
        let actionWeaponCurveY = SKAction.moveToY(shiftY, duration:3)
        
        banana.runAction(actionWeaponCurveY)
        
        let shiftX1 = gorilla.position.x + random(min: CGFloat(-120.0), max: CGFloat(-80))
        let actionWeaponCurveX1 = SKAction.moveToX(shiftX1, duration:1)
        let shiftX2 = gorilla.position.x + shiftX1 + random(min: CGFloat(160.0), max: CGFloat(240))
        let actionWeaponCurveX2 = SKAction.moveToX(shiftX2, duration:2)
        
        banana.runAction(SKAction.sequence([actionWeaponCurveX1, actionWeaponCurveX2]))
        
        // Create the actions
        //        let actionMove = SKAction.moveTo(CGPoint(x: -bunny.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        // If the carrot reaches to the destination successfully -> Game Over
        //        let loseAction = SKAction.runBlock() {
        //            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        //            let gameOverScene = GameOverScene(size: self.size, won: false)
        //            self.view?.presentScene(gameOverScene, transition: reveal)
        //        }
        
        //        carrot.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        // player life reduced
        let loseHeart = SKAction.runBlock() {
            self.playerlife--
            
            if (self.playerlife == 2) {
                self.playerheart_3.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 1) {
                self.playerheart_2.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 0) {
                self.playerheart_1.runAction(actionMoveDone)
            }
        }
        
        // player got hit screen
        let loseHeartAnimation = SKAction.runBlock() {
            self.player_hit(banana)
        }
        
        
        // show the gorilla
        let newdes = gorilla.position
        let actionPresent = SKAction.moveTo(newdes, duration: 3.0) // if duration>3, bunny collides with bunny -> Problem of collision prediction algorithm?
        gorilla.runAction(SKAction.sequence([actionPresent, actionMoveDone]))
        
        banana.runAction(SKAction.sequence([actionAttack, loseHeart, loseHeartAnimation, actionMoveDone]))
    }
    
    
    func addMonster3() {
        
        // Create Rhino sprite
        let rhino_back = SKSpriteNode(imageNamed: "rhino_back")
        rhino_back.size = CGSize(width: 50, height: 60)
        
        // give physics body to Rhino
        rhino_back.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(50,60))
        rhino_back.physicsBody?.dynamic = true
        rhino_back.physicsBody?.categoryBitMask = PhysicsCategory.Rhino_back
        rhino_back.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        rhino_back.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the Rhino along the Y axis
        //        let actualY = random(min: bunny.size.height/2, max: size.height - bunny.size.height/2)
        let actualY = CGFloat(150)
        
        // Position the Rhino slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        rhino_back.position = CGPoint(x: size.width*3/4, y: actualY)
        // rhino_back.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        addChild(rhino_back)

        let actionMoveDone = SKAction.removeFromParent()
        
        // show the rhino
        let newdes = rhino_back.position
        let actionPresent = SKAction.moveTo(newdes, duration: 3.0) // if duration>3, bunny collides with bunny -> Problem of collision prediction algorithm?
        rhino_back.runAction(SKAction.sequence([actionPresent, actionMoveDone]))
        
        }
    

    func player_hit(banana:SKSpriteNode) {
        // Sound
        runAction(SKAction.playSoundFileNamed("Glass-break.wav", waitForCompletion: false))
        
        // add the effect of crash of glass
        
        // Load picture of crash
        let got_hit = SKSpriteNode(imageNamed: "hitted")
        
        // rescale the picture
        got_hit.size = CGSize(width: 150, height: 150)
        
        got_hit.position = banana.position
        
        println("Player got hitted")
        
        addChild(got_hit)
        
        let actionMove = SKAction.moveTo(got_hit.position, duration: 0.6)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        got_hit.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        

    }
    
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Sound of throwing banana
        runAction(SKAction.playSoundFileNamed("throw_sound.mp3", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of Bullet
        let bullet = SKSpriteNode(imageNamed: "boom")
        
        bullet.size = CGSize(width: 30, height: 30)
        
        ////
        bullet.position = touchLocation
        
        // give physics body to bullet
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Bunny // bullet will check collision with Boss Bunny
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true

        
        // Determine rotational speed of the bullet
        //let actualRot = random(min: CGFloat(-50.0), max: CGFloat(-1.0))
        //let action = SKAction.rotateByAngle(actualRot, duration:1)
        
        //bullet.runAction(SKAction.repeatActionForever(action))
        
        // 3 - Determine offset of location to bullet
        //let offset = touchLocation - bullet.position
        
        // 4 - Bail out if you are shooting down or backwards
        //        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        
        
        addChild(bullet)
        
        // 6 - Get the direction of where to shoot
        //let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        //let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        //let realDest = shootAmount + bullet.position
        let realDest = bullet.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 0.5)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func bulletDidCollideWithCarrot(bullet:SKSpriteNode, carrot:SKSpriteNode) {
        // Sound of bullet hitting with carrot
        runAction(SKAction.playSoundFileNamed("Squish.mp3", waitForCompletion: false))
        
        println("Hit Carrot")
        bullet.removeFromParent()
        carrot.removeFromParent()
    }
    
    
    
    func bulletDidCollideWithBunny(bullet:SKSpriteNode, bunny:SKSpriteNode) {
        // Sound of banana hitting Boss Bunny
        runAction(SKAction.playSoundFileNamed("Pain_Sound.mp3", waitForCompletion: false))
        
        // Load picture of Bunny got hitted
        let shocked_bunny = SKSpriteNode(imageNamed: "shocked_bunny")
        
        // rescale the picture
        shocked_bunny.size = CGSize(width: 80, height: 80)
        
        shocked_bunny.position = bunny.position
        
        ///
        println("Hit Bunny")
        bullet.removeFromParent()
        bunny.removeFromParent()
        ///
        
        addChild(shocked_bunny)
        
        
        let newdes = shocked_bunny.position
        let actionMove = SKAction.moveTo(newdes, duration: 0.6)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        shocked_bunny.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
/*
        // Hit 2 times to win
        bunnyhitted++
        if (bunnyhitted > 1) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
*/
    }
    
    
    
    func bulletDidCollideWithGorilla(bullet:SKSpriteNode, gorilla:SKSpriteNode) {
        // Sound of banana hitting Boss Bunny
        runAction(SKAction.playSoundFileNamed("Pain_Sound.mp3", waitForCompletion: false))
        
        // Load picture of gorilla got hitted
        let shocked_gorilla = SKSpriteNode(imageNamed: "shocked_bunny")
        
        // rescale the picture
        shocked_gorilla.size = CGSize(width: 80, height: 80)
        
        shocked_gorilla.position = gorilla.position
        
        ///
        println("Hit Gorilla")
        bullet.removeFromParent()
        gorilla.removeFromParent()
        ///
        
        addChild(shocked_gorilla)
        
        
        let newdes = shocked_gorilla.position
        let actionMove = SKAction.moveTo(newdes, duration: 0.6)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        shocked_gorilla.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        /*
        // Hit 2 times to win
        bunnyhitted++
        if (bunnyhitted > 1) {
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameOverScene = GameOverScene(size: self.size, won: true)
        self.view?.presentScene(gameOverScene, transition: reveal)
        }
        */
    }
    
    
    
    
    
    func bulletDidCollideWithRhino_back(bullet:SKSpriteNode, rhino_back:SKSpriteNode) {
        // Sound of bullet hitting with Rhino_back
        runAction(SKAction.playSoundFileNamed("DINOSAUR.WAV", waitForCompletion: false))
        
        // give rhino life up to 2
        self.rhinolife = 2
        
        // Create attack from Rhino sprite
        let rhino_front = SKSpriteNode(imageNamed: "rhino-2")
        rhino_front.size = CGSize(width: 50, height: 60)
        
        // Add the Rhino_attack to the scene
        rhino_front.position = rhino_back.position
        
        // remove rhino_back
        println("Hit Rhino_back")
        rhino_back.removeFromParent()
        bullet.removeFromParent()
        
        // give physicsbody to rhino_front
        rhino_front.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(50,60))
        rhino_front.physicsBody?.dynamic = true

        /////////////
        rhino_front.physicsBody?.categoryBitMask = PhysicsCategory.Rhino_front
        rhino_front.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        rhino_front.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        addChild(rhino_front)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        
        // If the carrot reaches to the destination successfully -> Game Over
        //        let loseAction = SKAction.runBlock() {
        //            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        //            let gameOverScene = GameOverScene(size: self.size, won: false)
        //            self.view?.presentScene(gameOverScene, transition: reveal)
        //        }
        
        //        carrot.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        // player life reduced
        let loseHeart = SKAction.runBlock() {
            self.playerlife--
            
            if (self.playerlife == 2) {
                self.playerheart_3.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 1) {
                self.playerheart_2.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 0) {
                self.playerheart_1.runAction(actionMoveDone)
            }
        }
        

        // player got hit screen
        let loseHeartAnimation = SKAction.runBlock() {
            self.player_hit(rhino_front)
        }

        // Determine speed of the rhino_front
        var actualZoom = random(min: CGFloat(3.5), max: CGFloat(4.5))
        let actionAttack = SKAction.scaleTo(actualZoom, duration: 3)
        
        rhino_front.runAction(SKAction.sequence([actionAttack, loseHeart, loseHeartAnimation, actionMoveDone]))
        
        
    }
    
        
    func bulletDidCollideWithRhino_front(bullet:SKSpriteNode, rhino_front:SKSpriteNode) {
            // Sound of bullet hitting with Rhino_front
            runAction(SKAction.playSoundFileNamed("Squish.mp3", waitForCompletion: false))
            self.rhinolife--
            
            let actionMoveDone = SKAction.removeFromParent()
            
            println("Hit Rhino_front")
            bullet.removeFromParent()
        
            if (self.rhinolife == 0) {
                rhino_front.removeFromParent()
            }
    }
    
    

    func didBeginContact(contact: SKPhysicsContact) {
        // sort out the index of collision bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
/*        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
*/
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        
        switch contactMask {
        case PhysicsCategory.Carrot | PhysicsCategory.Bullet :
            println("Bullet hit Carrot\n")
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if ( secondBody.node == nil ) {
                break
            }
            
            bulletDidCollideWithCarrot(firstBody.node as! SKSpriteNode, bullet: secondBody.node as! SKSpriteNode)
            
            
        case PhysicsCategory.Bunny | PhysicsCategory.Bullet :
            println("Bullet hit Bunny\n")
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if ( firstBody.node == nil ) {
                break
            }
            bulletDidCollideWithBunny(firstBody.node as! SKSpriteNode, bunny: secondBody.node as! SKSpriteNode)
            
            
        case PhysicsCategory.Gorilla | PhysicsCategory.Bullet :
            println("Bullet hit Gorilla\n")
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if ( firstBody.node == nil ) {
                break
            }
            bulletDidCollideWithGorilla(firstBody.node as! SKSpriteNode, gorilla: secondBody.node as! SKSpriteNode)
            
            
        case PhysicsCategory.Rhino_back | PhysicsCategory.Bullet :
            println("Bullet hit Rhino_back\n")
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if ( firstBody.node == nil ) {
                break
            }
            
            bulletDidCollideWithRhino_back(firstBody.node as! SKSpriteNode, rhino_back: secondBody.node as! SKSpriteNode)
            
        case PhysicsCategory.Rhino_front | PhysicsCategory.Bullet :
            println("Bullet hit Rhino_front\n")
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if ( firstBody.node == nil ) {
                break
            }
            
            bulletDidCollideWithRhino_front(firstBody.node as! SKSpriteNode, rhino_front: secondBody.node as! SKSpriteNode)
            
        default:
            println()
            
        }
/*
        // debug to see the index
        println(firstBody.categoryBitMask)
        println(secondBody.categoryBitMask)
        
        
        // if bullet hits carrot
        if ((firstBody.categoryBitMask == PhysicsCategory.Carrot ) &&
            (secondBody.categoryBitMask == PhysicsCategory.Bullet )) {
                bulletDidCollideWithCarrot(firstBody.node as! SKSpriteNode, bullet: secondBody.node as! SKSpriteNode)
        }
        
        // if bullet hits Boss Bunny
        if ((firstBody.categoryBitMask == PhysicsCategory.Bullet ) &&
            (secondBody.categoryBitMask == PhysicsCategory.Bunny) ) {
                
            bulletDidCollideWithBunny(firstBody.node as! SKSpriteNode, bunny: secondBody.node as! SKSpriteNode)
        }
*/
    }

}
