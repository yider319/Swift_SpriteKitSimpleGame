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
    static let Bullet   : UInt32 = 0b00001  // 1
    static let Carrot   : UInt32 = 0b00010  // 2
    static let Bunny     : UInt32 = 0b00011   // 3
    static let Gorilla     : UInt32 = 0b00100   // 4
    static let Rhino_back     : UInt32 = 0b00101   // 5
    static let Rhino_front     : UInt32 = 0b00110   // 6
}


class GameScene: SKScene, SKPhysicsContactDelegate{
    // Flag indicating whether we've setup the camera system yet.
    var isCreated: Bool = false
    
    // The root node of your game world. Attach game entities
    // (player, enemies, &c.) to here.
    var world: SKNode?
    // The root node of our UI. Attach control buttons & state
    // indicators here.
    var overlay: SKNode?
    // The camera. Move this node to change what parts of the world are visible.
    var camera: SKNode?
    
    // 1 player life
    var playerlife = 5
    
    // 2 monster rhino life
    var rhinolife = 2
    
    let playerheart_1 = SKSpriteNode(imageNamed: "heart")
    let playerheart_2 = SKSpriteNode(imageNamed: "heart")
    let playerheart_3 = SKSpriteNode(imageNamed: "heart")
    let playerheart_4 = SKSpriteNode(imageNamed: "heart")
    let playerheart_5 = SKSpriteNode(imageNamed: "heart")
    
    
    override func didMoveToView(view: SKView) {
        playBackgroundMusic("cautious-path.mp3")
        
        backgroundColor = SKColor.whiteColor()

        if !isCreated {
            isCreated = true
            
            // Camera setup
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.world = SKNode()
            self.world?.name = "world"
            addChild(self.world!)
            self.camera = SKNode()
            self.camera?.name = "camera"
            self.world?.addChild(self.camera!)
            
            // UI setup
            self.overlay = SKNode()
            self.overlay?.zPosition = 10
            self.overlay?.name = "overlay"
            addChild(self.overlay!)
        }
        
        // add background to "world"
        let bg = SKSpriteNode(imageNamed: "forest")
        
        playerheart_1.position = CGPoint(x: size.width * 0.25, y: size.height * 0.44)
        playerheart_1.size = CGSize(width: 35, height: 35)
        
        playerheart_2.position = CGPoint(x: size.width * 0.3, y: size.height * 0.44)
        playerheart_2.size = CGSize(width: 35, height: 35)
        
        playerheart_3.position = CGPoint(x: size.width * 0.35, y: size.height * 0.44)
        playerheart_3.size = CGSize(width: 35, height: 35)
        
        playerheart_4.position = CGPoint(x: size.width * 0.4, y: size.height * 0.44)
        playerheart_4.size = CGSize(width: 35, height: 35)
        
        playerheart_5.position = CGPoint(x: size.width * 0.45, y: size.height * 0.44)
        playerheart_5.size = CGSize(width: 35, height: 35)
        
        self.overlay?.addChild(playerheart_1)
        self.overlay?.addChild(playerheart_2)
        self.overlay?.addChild(playerheart_3)
        self.overlay?.addChild(playerheart_4)
        self.overlay?.addChild(playerheart_5)
        
        bg.position = CGPoint(x: frame.size.width * 0.0, y: frame.size.width * 0.2)
        
        bg.size = CGSize(width: 680, height: 650)
        
        self.world?.addChild(bg)
        
        
        // ?? which world?
        physicsWorld.gravity = CGVectorMake(0,0)
        physicsWorld.contactDelegate = self
        

        self.world?.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.waitForDuration(1),
                SKAction.runBlock(addMonster1),
                SKAction.waitForDuration(5),
                SKAction.runBlock(addMonster2),
                SKAction.waitForDuration(5.0)
            ])
        ))

        
        self.world?.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.waitForDuration(15),
                SKAction.runBlock(addMonster3),
                SKAction.waitForDuration(5),
                SKAction.runBlock(addMonster4),
                SKAction.waitForDuration(5.0)
            ])
        ))


        
        // moving camera
        //self.camera?.runAction(SKAction.moveTo(CGPointMake(100, 50), duration: 1.0))
        
    }
    
    
    override func didSimulatePhysics() {
        if self.camera != nil {
            self.centerOnNode(self.camera!)
        }
    }
    
    
    func centerOnNode(node: SKNode) {
        let cameraPositionInScene: CGPoint = node.scene!.convertPoint(node.position, fromNode: node.parent!)
        
        node.parent!.position = CGPoint(x:node.parent!.position.x - cameraPositionInScene.x, y:node.parent!.position.y - cameraPositionInScene.y)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    /////
    // rescale the physics shape part 1
    func offset(node: SKSpriteNode, isX: Bool)->CGFloat {
        return isX ? node.frame.size.width * node.anchorPoint.x : node.frame.size.height * node.anchorPoint.y
    }
    
    // rescale the physics shape part 2
    func AddLineToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathAddLineToPoint(path, nil, (x * 1/2.2) - offset(node, isX: true), (y * 1/2.2) - offset(node, isX: false))
    }
    
    // rescale the physics shape part 3
    func MoveToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathMoveToPoint(path, nil, (x * 1/2.2) - offset(node, isX: true), (y * 1/2.2) - offset(node, isX: false))
    }
    /////
    
    
    //
    func addMonster1() {
        // play crazy sound
        runAction(SKAction.playSoundFileNamed("crazy_laugh.mp3", waitForCompletion: false))
        // Create Boss Bunny sprite
        let bunny = SKSpriteNode(imageNamed: "Bugs_Bunny")
        bunny.size = CGSize(width: 70, height: 100)
        
        // Create attack from Boss Bunny sprite
        let carrot = SKSpriteNode(imageNamed: "carrot")
        carrot.size = CGSize(width: 15, height: 40)
        
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
        let actualY = CGFloat(-50)
        
        // Position the bunny slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        // bunny.position = CGPoint(x: size.width - bunny.size.width/2, y: actualY)
        bunny.position = CGPoint(x: size.width*1/5, y: actualY)
        
        // Add the carrot to the scene
        carrot.position = bunny.position
        
        // give physicsbody to carrot
        carrot.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10,40))
        carrot.physicsBody?.dynamic = true
        carrot.physicsBody?.categoryBitMask = PhysicsCategory.Carrot
        carrot.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        carrot.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        self.world?.addChild(bunny)
        self.world?.addChild(carrot)
        
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
            println(self.playerlife)
            
            if (self.playerlife == 4) {
                self.playerheart_1.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 3) {
                self.playerheart_2.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 2) {
                self.playerheart_3.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 1) {
                self.playerheart_4.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 0) {
                self.playerheart_5.runAction(actionMoveDone)
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
        //bunny.runAction(actionPresent)
        
        carrot.runAction(SKAction.sequence([actionAttack, loseHeart , loseHeartAnimation, actionMoveDone]))
    }

    
    //
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
        gorilla.physicsBody?.categoryBitMask = PhysicsCategory.Gorilla
        gorilla.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        gorilla.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the Gorilla along the Y axis
        //        let actualY = random(min: bunny.size.height/2, max: size.height - bunny.size.height/2)
        let actualY = CGFloat(-100)
        
        // Position the bunny slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        gorilla.position = CGPoint(x: -size.width*0, y: actualY)
        //gorilla.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        // Add the banana to the scene
        banana.position = gorilla.position
        
        // give physicsbody to carrot
        banana.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(15,20))
        banana.physicsBody?.dynamic = true
        banana.physicsBody?.categoryBitMask = PhysicsCategory.Carrot
        banana.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        banana.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        self.world?.addChild(gorilla)
        self.world?.addChild(banana)
        
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
            println(self.playerlife)
            
            if (self.playerlife == 4) {
                self.playerheart_1.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 3) {
                self.playerheart_2.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 2) {
                self.playerheart_3.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 1) {
                self.playerheart_4.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 0) {
                self.playerheart_5.runAction(actionMoveDone)
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
    
    //
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
        let actualY = CGFloat(-100)
        
        // Position the Rhino slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        rhino_back.position = CGPoint(x: -size.width*2/5, y: actualY)
        // rhino_back.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.world?.addChild(rhino_back)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        // show the rhino
        let actionPresent = SKAction.waitForDuration(3.0) // if duration>3, bunny collides with bunny -> Problem of collision prediction algorithm?
        rhino_back.runAction(SKAction.sequence([actionPresent, actionMoveDone]))
        
    }
    
    //
    func addMonster4() {
        
        // Create Boxing Kangaroo sprite
        let kangaroo = SKSpriteNode(imageNamed: "kangaroo-boxing")
        kangaroo.size = CGSize(width: 60, height: 90)
        
        // give physics body to Boxing Kangaroo
        kangaroo.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(35,65))
        kangaroo.physicsBody?.dynamic = true
        kangaroo.physicsBody?.categoryBitMask = PhysicsCategory.Bunny
        kangaroo.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // will test with Bullet
        kangaroo.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the Monster along the Y axis
        //        let actualY = random(min: bunny.size.height/2, max: size.height - bunny.size.height/2)
        let actualY = CGFloat(-50)
        
        // Position the bunny slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        // bunny.position = CGPoint(x: size.width - bunny.size.width/2, y: actualY)
        kangaroo.position = CGPoint(x: -size.width*1/5, y: actualY)
        
        self.world?.addChild(kangaroo)
        
        // Determine speed of the kangaroo
        var actualZoom = random(min: CGFloat(4.5), max: CGFloat(6.0))
        let actionAttack = SKAction.scaleTo(actualZoom, duration: 2)
        
        // Kangaroo stay still for 1 second
        let actionStandby = SKAction.waitForDuration(1)

        // animate the kangaroo (zoom), attack from Boxing Kangaroo sprite
        kangaroo.runAction(SKAction.sequence([actionStandby, actionAttack, actionStandby]))
        
        // Determine jump speed of the kangaroo
        let actualHeight = actualY + CGFloat(1000)
        let actionJumpUp = SKAction.moveToY(actualHeight, duration:1)
        let actualGround = actualY - CGFloat(100)
        let actionJumpDown = SKAction.moveToY(actualGround, duration:1)
        
        // Create the actions
        //        let actionMove = SKAction.moveTo(CGPoint(x: -bunny.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        

        // player life reduced
        let loseHeart = SKAction.runBlock() {
            self.playerlife--
            println(self.playerlife)
            
            if (self.playerlife == 4) {
                self.playerheart_1.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 3) {
                self.playerheart_2.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 2) {
                self.playerheart_3.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 1) {
                self.playerheart_4.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 0) {
                self.playerheart_5.runAction(actionMoveDone)
            }
        }


        // player got hit screen
        let loseHeartAnimation = SKAction.runBlock() {
            self.player_hit(kangaroo)
            
        }
        
        // moving camera; Kangaroo Uppercut
        let actionCameraUp = SKAction.moveToY(CGFloat(250), duration:0.2)
        let actionCameraDown = SKAction.moveToY(CGFloat(0), duration:0.4)
        
        let actionUppercut = SKAction.runBlock() {
            self.camera?.runAction(SKAction.sequence([actionCameraUp, actionCameraDown]))
        }
        
        kangaroo.runAction(SKAction.sequence([actionStandby, actionJumpUp, actionJumpDown, actionStandby, loseHeartAnimation, actionUppercut, loseHeart, actionMoveDone]))
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
        
        self.overlay?.addChild(got_hit)
        
        let actionMove = SKAction.moveTo(got_hit.position, duration: 0.6)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        got_hit.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Sound of gun shoot
        runAction(SKAction.playSoundFileNamed("gun.mp3", waitForCompletion: false))
        
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
        
        
        self.world?.addChild(bullet)
        
        let realDest = bullet.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 0.5)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        
        // Load picture of Gun
        let gun = SKSpriteNode(imageNamed: "RHG")
    
        gun.size = CGSize(width: 120, height: 120)
        
        gun.position = CGPointMake(self.frame.size.width*3/7, -self.frame.size.height/2)
        gun.position.y = gun.position.y + CGFloat(50)
        
        self.overlay?.addChild(gun)

        let actionGun = SKAction.waitForDuration(0.6)
        gun.runAction(SKAction.sequence([actionGun, actionMoveDone]))

    }
    
    
    func bulletDidCollideWithBunny(bullet:SKSpriteNode, bunny:SKSpriteNode) {
        // Sound of hitting Bunny
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
        
        self.world?.addChild(shocked_bunny)
        
        let actionMove = SKAction.waitForDuration(0.6)
        
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
    
    func bulletDidCollideWithCarrot(bullet:SKSpriteNode, carrot:SKSpriteNode) {
        // Sound of bullet hitting with carrot
        // runAction(SKAction.playSoundFileNamed("Squish.mp3", waitForCompletion: false))
        
        println("Hit Carrot")
        bullet.removeFromParent()
        carrot.removeFromParent()
        
        // Load picture of Boom
        let boom = SKSpriteNode(imageNamed: "boom")
        
        // rescale the picture
        boom.size = CGSize(width: 80, height: 80)
        
        boom.position = carrot.position
        
        self.world?.addChild(boom)
        
        let actionMove = SKAction.waitForDuration(0.4)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        boom.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func bulletDidCollideWithGorilla(bullet:SKSpriteNode, gorilla:SKSpriteNode) {
        // Sound of banana hitting Boss Bunny
        runAction(SKAction.playSoundFileNamed("gorilla_hit.wav", waitForCompletion: false))
        
        // Load picture of gorilla got hitted
        let shocked_gorilla = SKSpriteNode(imageNamed: "gorilla_shocked")
        
        // rescale the picture
        shocked_gorilla.size = CGSize(width: 120, height: 120)
        
        shocked_gorilla.position = gorilla.position
        
        ///
        println("Hit Gorilla")
        bullet.removeFromParent()
        gorilla.removeFromParent()
        ///
        
        self.world?.addChild(shocked_gorilla)
        
        
        let newdes = shocked_gorilla.position
        let actionMove = SKAction.moveTo(newdes, duration: 0.6)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        shocked_gorilla.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    func bulletDidCollideWithRhino_back(bullet:SKSpriteNode, rhino_back:SKSpriteNode) {
        // Sound of bullet hitting with Rhino_back
        runAction(SKAction.playSoundFileNamed("DINOSAUR.WAV", waitForCompletion: false))
        
        // give rhino life up to 3
        self.rhinolife = 3
        
        // Create attack from Rhino sprite
        let rhino_front = SKSpriteNode(imageNamed: "rhino-2")
        rhino_front.size = CGSize(width: 50, height: 60)
        
        // Add the Rhino_attack to the scene
        rhino_front.position = rhino_back.position
        rhino_front.position = rhino_front.position + CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        //not sure why?
        
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
        
        
        self.world?.addChild(rhino_front)
        
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
            println(self.playerlife)
            
            if (self.playerlife == 4) {
                self.playerheart_1.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 3) {
                self.playerheart_2.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 2) {
                self.playerheart_3.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 1) {
                self.playerheart_4.runAction(actionMoveDone)
            }
            
            if (self.playerlife == 0) {
                self.playerheart_5.runAction(actionMoveDone)
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
        
        // Sound of gun hit
        runAction(SKAction.playSoundFileNamed("gun_hit.mp3", waitForCompletion: false))
        
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
        
        // only if the first one is a "bullet," then we are sure it is a collision
        if (firstBody.categoryBitMask == 1) {
            
            let contactMask = secondBody.categoryBitMask
            println(contactMask)
            
            switch contactMask {
            case PhysicsCategory.Carrot :
                println("Bullet hit Carrot\n")
                
                if ( firstBody.node == nil ) {
                    break
                }
                
                bulletDidCollideWithCarrot(firstBody.node as! SKSpriteNode, carrot: secondBody.node as! SKSpriteNode)
                
                
            case PhysicsCategory.Bunny :
                println("Bullet hit Bunny\n")
                
                if ( firstBody.node == nil ) {
                    break
                }
                bulletDidCollideWithBunny(firstBody.node as! SKSpriteNode, bunny: secondBody.node as! SKSpriteNode)
                
                
            case PhysicsCategory.Gorilla :
                println("Bullet hit Gorilla\n")
                
                if ( firstBody.node == nil ) {
                    break
                }
                bulletDidCollideWithGorilla(firstBody.node as! SKSpriteNode, gorilla: secondBody.node as! SKSpriteNode)
                
                
            case PhysicsCategory.Rhino_back :
                println("Bullet hit Rhino_back\n")
                
                if ( firstBody.node == nil ) {
                    break
                }
                
                bulletDidCollideWithRhino_back(firstBody.node as! SKSpriteNode, rhino_back: secondBody.node as! SKSpriteNode)
                
            case PhysicsCategory.Rhino_front :
                println("Bullet hit Rhino_front\n")
                
                if ( firstBody.node == nil ) {
                    break
                }
                
                bulletDidCollideWithRhino_front(firstBody.node as! SKSpriteNode, rhino_front: secondBody.node as! SKSpriteNode)
                
                
            default:
                println()
            }
            
        }
    
}
    
}
