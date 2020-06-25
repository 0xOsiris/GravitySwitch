//
//  GameScene.swift
//  RetroRoute
//
//  Created by Leyton Taylor on 4/5/20.
//  Copyright © 2020 Leyton Taylor. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit
import UIKit



//Declaration of Physics Categories
struct PhysicsCategory {
    static let Main : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Obstacle : UInt32 = 0x1 << 3
    static let Token : UInt32 = 0x1 << 5
    static let Ceiling : UInt32 = 0x1 << 4
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController : GameViewController!
    var moveObstacleStar = SKAction()
    var moveAndRemoveStar = SKAction()
    var interstitialDelegate : GADInterstitialDelegate?
    
    var moveObstacle1 = SKAction()
    //sequence actions used for spawning obstacles
    var moveAndRemove = SKAction()
    var moveAndRemove1 = SKAction()
    var moveAndRemove4 = SKAction()
    var moveAndRemove5 = SKAction()
    //SKAction for rotation
    var repeatRotation = SKAction()
    //Clockwise and counter clockwise rotation SKActions
    var rotateClock = SKAction()
    var rotateClockSaber = SKAction()
    var rotateClockSaber1 = SKAction()
    var rotateCounter = SKAction()
    //SKActions to move main character from bottom to top or top to bottom of screen
    //On swipe up or down
    var moveUp = SKAction()
    var moveDown = SKAction()
    //SKActions to change the color of background from red to blue
    var moveGravDown = SKAction()
    var moveGravUp = SKAction()
    //Action to act on obstacles
    var imPulseAction = SKAction()
    
    //SKNode() objects containing multiple obstacles
    var obstaclePair = SKNode()
    var obstaclePair1 = SKNode()
    var obstaclePair4 = SKNode()
    var obstaclePair5 = SKNode()
    var obstaclePairStar = SKNode()
    
    //Initial text displayed on screen
    let taptoPlay = SKLabelNode(fontNamed: "Chalkduster")
    //Label to keep track of score
    var scoreLabel = SKLabelNode(fontNamed: "PingFang TC")
    var finalScore = SKLabelNode(fontNamed: "PingFang TC")
    //UISwipeGestureRecognizer that can detect when there is a swipe up or down by the user
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    
    //Initial boolean values for runtime dynamics of the game
    //negGravity = false once player swipes up negGravity = true
    //died == true ==> player made contact with an obstacle
    //gameStarted Bool to determine when game is in progress
    //leftMain = false if on main menu screen
    var negGravity = Bool()
    
    var gamePaused = false
    var gameStarted = Bool()
    var leftMain = Bool()
    var scoreVal: Int64 = 0
    
    var randY = Int()
    var randY3 = Int()
    var randY4 = Int()
    var died = false
    //Instantiation of Ground, Ceiling and Main= main character
    var Ground = SKSpriteNode()
    var Ceiling = SKSpriteNode()
    var Main = SKSpriteNode()
    //Background color Red SKSpriteNodces()
    var antiGravityBar1 = SKSpriteNode()
    //Background color Blue SKSpriteNodce
    var gravityBar1 = SKSpriteNode()
    //Restarte button
    var restartBTN = SKSpriteNode()
    //Settings button on main menu
    var settingsButton = SKSpriteNode()
    //ShopButton on main menu
    var shopButton = SKSpriteNode()
    //Background SKPriteNodce() object---changes image between gameplay and mainmenu screeen
    var background = SKSpriteNode()
    var backgroundSprite = SKSpriteNode()
    
    var gameLevel:Int64 = 0
    var levelReached = Bool()
    var scoreStarted = Bool()
    
    var banner = SKSpriteNode()
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        background.removeFromParent()
        self.scoreStarted = false
        self.died = false
        self.gamePaused = false
        gameLevel = 1
        gameStarted = false
        negGravity = false
        
        
        createScene()
        
    }
    
    //Loads interstitial ad after level if the interstitial ad is
    //ready
    func loadInterstitialAd(){
        self.interstitialDelegate?.showInterstitial()
    }
    
    //Main menu screen method. Called when app initially starts
    //and when main menu button is clicked
    func mainMenu(){
        self.removeAllChildren()
        
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MainMenu(fileNamed:"MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                scene.size = view.bounds.size
                scene.viewController = self.viewController
                scene.gameCenterDelegate = self.viewController
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            
        }
        
    }
    
    
    
    //Takes to main menu screen
    func resetMain(){
        self.removeAllChildren()
        self.scoreStarted = false
        self.died = false
        self.gameStarted = false
        negGravity=false
        mainMenu()
    }
    
    
    //Called each time the gameplay is started
    //Attaches all of the sprite nodes to the parent view
    func createScene(){
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -7)
        self.scoreStarted = false
        //Background declaration
        background = SKSpriteNode(imageNamed: "mainmenuFinalGame")
        background.name = "background"
        background.size.height = self.frame.size.height
        background.size.width=self.frame.size.width
        background.position = CGPoint(x: 0, y: 0)
        
        gameLevel = 1
        scoreVal = 0
        scoreLabel.text = String(scoreVal)
        
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        //Gesture swipe up recognizer
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp) )
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        //Gesture swipe down recognizer
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown) )
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
        
        //Declaration of background colors
        gravityBar1 = SKSpriteNode(imageNamed: "BlueColor")
        antiGravityBar1 = SKSpriteNode(imageNamed: "RedColor")
        
        
        gravityBar1.position = CGPoint(x: 0, y: 0)
        antiGravityBar1.size.width = self.frame.size.width
        antiGravityBar1.size.height = self.frame.size.height
        antiGravityBar1.position = CGPoint(x: 0, y: 0 - (self.frame.size.height / 2) - (gravityBar1.size.height / 2))
        
        
        gravityBar1.zPosition = -2
        antiGravityBar1.zPosition = -1
        
        //Declaration of Ground object
        Ground = SKSpriteNode(color: .clear, size: CGSize(width: self.frame.size.width, height: self.frame.size.height / 21))
        Ground.position=CGPoint(x: 0, y: 0 - (self.frame.height / 2) + (Ground.frame.height / 2))
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        
        
        //Declaration of Ceiling object
        Ceiling = SKSpriteNode(color: .clear, size: CGSize(width: self.frame.size.width, height: self.frame.size.height / 21))
        Ceiling.position=CGPoint(x: 0, y: 0 + (self.frame.size.height / 2) - (Ceiling.frame.size.height / 2))
        Ceiling.physicsBody = SKPhysicsBody(rectangleOf: Ceiling.size)
        Ceiling.physicsBody?.categoryBitMask = PhysicsCategory.Ceiling
        Ceiling.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ceiling.physicsBody?.affectedByGravity = false
        Ceiling.physicsBody?.isDynamic = false
        
        
        //Declaration of main character Main
        Main = SKSpriteNode(imageNamed: "sprite")
        Main.size = CGSize(width: self.frame.size.width / 7 - 5, height: self.frame.size.width / 7 - 5)
        Main.position=CGPoint(x: 0, y: 0)
        Main.physicsBody = SKPhysicsBody(circleOfRadius: Main.frame.size.height / 2)
        Main.physicsBody?.categoryBitMask = PhysicsCategory.Main
        Main.physicsBody?.collisionBitMask = PhysicsCategory.Ceiling | PhysicsCategory.Ground | PhysicsCategory.Obstacle
        Main.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Ceiling | PhysicsCategory.Obstacle
        Main.physicsBody?.affectedByGravity = true
        Main.physicsBody?.isDynamic = true
        Main.zPosition=2
        
        self.addChild(Main)
        self.addChild(Ground)
        self.addChild(Ceiling)
        self.addChild(gravityBar1)
        self.addChild(antiGravityBar1)
        self.addChild(background)
        
    }
    
    //Creates a half reset half main menu button and displays it to the screen with and animation
    func createRestartBTN(){
        restartBTN = SKSpriteNode(imageNamed: "Restart")
        restartBTN.size = CGSize(width: self.frame.size.width - 100, height: self.frame.size.width - 100)
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    
    
    //Initially calls mainMenu() when Application is started
    override func didMove(to view: SKView) {
        background = self.childNode(withName: "backgroundGame") as! SKSpriteNode
        background.texture = SKTexture(imageNamed: "mainmenuFinalGame")
        background.name = "background"
        background.size.height = self.frame.size.height
        background.size.width=self.frame.size.width
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        createScene()
    }
    
    
    //Contact method which detects contact between two bodies. Sets died = true if contact is found between Main and another hostile
    //Object
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if firstBody.categoryBitMask == PhysicsCategory.Main && secondBody.categoryBitMask == PhysicsCategory.Obstacle || firstBody.categoryBitMask == PhysicsCategory.Obstacle && secondBody.categoryBitMask == PhysicsCategory.Main{
            
            enumerateChildNodes(withName: "obstaclePair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            
            if self.died == false{
                let finalScore = SKLabelNode(fontNamed: "PingFang TC")
                if(self.scoreVal > UserDefaults().integer(forKey: "HighScore")){
                    saveHighScore(highScore: self.scoreVal)
                    finalScore.text = "New High Score!!: " + String(self.scoreVal)
                }else{
                    finalScore.text = "Final Score: " + String(self.scoreVal)
                }
                
                if(self.scoreVal > 1300){
                    loadInterstitialAd()
                }
                
                finalScore.zPosition = 8
                finalScore.position = CGPoint(x: self.frame.midX, y: self.frame.midY + (self.frame.size.height / 4))
                finalScore.fontSize = 25
                finalScore.fontColor = SKColor.white
                self.addChild(finalScore)
                
                self.scoreStarted = false
                self.died = true
                self.addScoreAndSubmitToGC(scoreVal: self.scoreVal)
                self.scoreVal=0
                
                self.scoreLabel.text = String(0)
                
                createRestartBTN()
                    
                
                
            }
        }
        
        
    }
    
    
    func saveHighScore(highScore: Int64){
        UserDefaults.standard.set(highScore, forKey: "HighScore")
    }
    //Negates gravity changes background color and Moves Main
    //To Ceiling
    @objc func swipedUp() {
        negGravity = true
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 7)
        moveUp = SKAction.move(to : CGPoint(x: 0, y:0 + (self.frame.size.height / 2) - (Ceiling.size.height) - (Main.size.height / 2)),duration: TimeInterval(0.25))
        moveGravUp = SKAction.move(to : CGPoint(x: 0, y:0),duration: TimeInterval(0.5))
        antiGravityBar1.run(moveGravUp)
        Main.run(moveUp)
        print("Up")
        
        
    }
    
    //Negates gravity, changes background color to blue and Moves Main to bottom of screen
    @objc func swipedDown() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -7)
        
        moveDown = SKAction.move(to : CGPoint(x: 0, y:0 - (self.frame.size.height / 2) + (Ceiling.frame.height) + (Main.frame.height / 2)),duration: TimeInterval(0.25))
        
        moveGravDown = SKAction.move(to : CGPoint(x: 0, y:0 - (self.frame.size.height / 2) - (antiGravityBar1.size.height / 2)),duration: TimeInterval(0.5))
        
        antiGravityBar1.run(moveGravDown)
        
        Main.run(moveDown)
        negGravity = false
        print("Down")
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        taptoPlay.text=""
        
        let delay = SKAction.wait(forDuration: 10, withRange: 2)
        let delaySaber = SKAction.wait(forDuration: 30, withRange: 3)
        let delaySaw = SKAction.wait(forDuration: 20, withRange: 5)
        let delayHedge = SKAction.wait(forDuration: 17, withRange: 3)
        if gameStarted == false{
            levelReached = false
            gameStarted = true
            
            if negGravity == false{
                
                Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                Main.physicsBody?.applyImpulse(CGVector(dx : 0,dy : 30))
                rotateCounter = SKAction.rotate(byAngle: CGFloat.pi *  -2, duration: 1)
                repeatRotation = SKAction.repeatForever(rotateCounter)
                Main.run(repeatRotation)
                
            }else{
                rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
                repeatRotation = SKAction.repeatForever(rotateClock)
                Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                Main.physicsBody?.applyImpulse(CGVector(dx : 0,dy : -30))
                Main.run(repeatRotation)
            }
            
        }else{
            if self.died == true{
                
            }else{
                if(!self.scoreStarted){
                    self.scoreStarted = true
                }
                
                let spawn = SKAction.run({
                    () in
                
                    self.createObstacle1()
                        
                })
                    
                let spawn1 = SKAction.run({
                    () in
                        
                    self.createStar1()
                        
                })
                    
                let spawn2 = SKAction.run({
                    () in
                        
                    self.createObstacle3()
                })
                
                let spawn3 = SKAction.run({
                    () in
                    
                    self.createHedge()
                })
                
                
                let spawn5 = SKAction.run({
                    () in
                        
                    self.createStar()
                        
                })
                
                let spawn6 = SKAction.run({
                    () in
                        
                    self.createHedge1()
                        
                })

                
                let SpawnDelay = SKAction.sequence([delaySaw,spawn])
                let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
                
                let SpawnDelay1 = SKAction.sequence([spawn1, delay])
                let spawnDelayForever1 = SKAction.repeatForever(SpawnDelay1)
                
                
                let SpawnDelay2 = SKAction.sequence([spawn2, delaySaber])
                let spawnDelayForever2 = SKAction.repeatForever(SpawnDelay2)
                
                let SpawnDelay3 = SKAction.sequence([spawn3, delayHedge])
                let spawnDelayForever3 = SKAction.repeatForever(SpawnDelay3)
                
                let SpawnDelay4 = SKAction.sequence([spawn5, delay])
                let spawnDelayForever4 = SKAction.repeatForever(SpawnDelay4)
                
                let SpawnDelay5 = SKAction.sequence([spawn6, delayHedge])
                let spawnDelayForever5 = SKAction.repeatForever(SpawnDelay5)
                
                
                switch gameLevel {
                    case 1 :
                        if(!levelReached){
                            self.run(spawnDelayForever)
                            self.run(spawnDelayForever1)
                            levelReached = true
                        }
                        
                    case 2 :
                        if(!levelReached){
                            self.run(spawnDelayForever2)
                            self.run(spawnDelayForever3)
                            levelReached = true
                        }
                        
                    
                    case 3 :
                        if(!levelReached){
                            
                            
                            self.run(spawnDelayForever4)
                            levelReached = true
                        }
                        
                    
                    case 4 :
                        if(!levelReached){
                            self.run(spawnDelayForever1)
                            
                            self.run(spawnDelayForever5)
                            levelReached = true
                        }
                        

                default:
                    break
                }
                
                
                if negGravity == false{
                    Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                    Main.physicsBody?.applyImpulse(CGVector(dx : 0, dy : 30))
                    rotateCounter = SKAction.rotate(byAngle: CGFloat.pi *  -2, duration: 1)
                    repeatRotation = SKAction.repeatForever(rotateCounter)
                    Main.run(repeatRotation)
                }else{
                    rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
                    repeatRotation = SKAction.repeatForever(rotateClock)
                    Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                    Main.physicsBody?.applyImpulse(CGVector(dx : 0,dy : -30))
                    Main.run(repeatRotation)
                }
            }
        }
        
        for touch in touches{
            let location = touch.location(in:self)
            
            if self.died == true{
                if restartBTN.contains(_:location){
                    if location.y > restartBTN.anchorPoint.y{
                        self.gamePaused = false
                        self.died = false
                       
                        restartScene()
                        
                    }else {
                        
                        resetMain()
                        
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    //Second obstacle creation method
    func createStar1(){
        obstaclePair1 = SKNode()
        obstaclePair1.name = "obstaclePair1"
        
        let randImpulse = Int.random(in: 0..<5)
        
        
        randY = Int.random(in: -5..<5)
        
        let distance = CGFloat(self.frame.size.width + 50)
        let removeObstacle = SKAction.removeFromParent()
        
        let throwingStar = SKSpriteNode(imageNamed:"ThrowingStar")
        let throwingStar1 = SKSpriteNode(imageNamed:"ThrowingStar")
        
        throwingStar.size = CGSize(width: self.frame.size.width / 5, height: self.frame.size.width / 5)
        
        throwingStar1.size = CGSize(width: self.frame.size.width / 5, height: self.frame.size.width / 5)
        
        throwingStar.physicsBody = SKPhysicsBody(circleOfRadius: throwingStar.frame.width / 2)
        throwingStar.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        throwingStar.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar.physicsBody?.isDynamic = false
        throwingStar.physicsBody?.affectedByGravity = false
        throwingStar.zRotation = CGFloat(Double.pi)
        
        
        
        throwingStar1.physicsBody = SKPhysicsBody(circleOfRadius: throwingStar1.frame.width / 2)
        throwingStar1.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        throwingStar1.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar1.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar1.physicsBody?.isDynamic = false
        throwingStar1.physicsBody?.affectedByGravity = false
        
        throwingStar1.zRotation = CGFloat(Double.pi)
        
        throwingStar.position=CGPoint(x: 0 + (self.frame.width / 2), y: 0 + (self.frame.height / 2) - (throwingStar.frame.height / 2)-200 + 60)
        throwingStar1.position=CGPoint(x: 0 + (self.frame.width / 2), y: 0 - 100 + 60)
        
        
        moveObstacleStar = SKAction.moveBy(x: -distance, y:  CGFloat(randY * 100), duration: TimeInterval(0.03 * distance))
                
        
        moveAndRemoveStar = SKAction.sequence([moveObstacleStar,removeObstacle])
        
        
        
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.25)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        throwingStar.run(repeatRotation)
        throwingStar1.run(repeatRotation)
        
        throwingStar.run(imPulseAction)
        throwingStar1.run(imPulseAction)
        
        
        obstaclePair1.addChild(throwingStar)
        obstaclePair1.addChild(throwingStar1)
        
        obstaclePair1.zPosition = 1
        obstaclePair1.run(moveAndRemoveStar)
        
        self.addChild(obstaclePair1)
        
    }
    
    //Second obstacle creation method
   func createStar(){
       obstaclePairStar = SKNode()
       obstaclePairStar.name = "obstaclePairStar"
       
       let randImpulse = Int.random(in: 0..<10)
       
       
       randY = Int.random(in: -5..<5)
       
       let distance = CGFloat(self.frame.size.width + 50)
       let removeObstacle = SKAction.removeFromParent()
       
       let throwingStar = SKSpriteNode(imageNamed:"ThrowingStar")
       let throwingStar1 = SKSpriteNode(imageNamed:"ThrowingStar")
       
       throwingStar.size = CGSize(width: self.frame.size.width / 5, height: self.frame.size.width / 5)
       
       throwingStar1.size = CGSize(width: self.frame.size.width / 5, height: self.frame.size.width / 5)
       
       throwingStar.physicsBody = SKPhysicsBody(circleOfRadius: throwingStar.frame.width / 2)
       throwingStar.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
       throwingStar.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
       throwingStar.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
       throwingStar.physicsBody?.isDynamic = false
       throwingStar.physicsBody?.affectedByGravity = false
       throwingStar.zRotation = CGFloat(Double.pi)
       
       
       
       throwingStar1.physicsBody = SKPhysicsBody(circleOfRadius: throwingStar1.frame.width / 2)
       throwingStar1.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
       throwingStar1.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
       throwingStar1.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
       throwingStar1.physicsBody?.isDynamic = false
       throwingStar1.physicsBody?.affectedByGravity = false
       
       throwingStar1.zRotation = CGFloat(Double.pi)
       
               
           
       throwingStar.position=CGPoint(x: 0 - (self.frame.size.width / 2), y: 0 + (self.frame.size.height / 2) - (throwingStar.frame.size.height / 2)-200 + 60)
       throwingStar1.position=CGPoint(x: 0 - (self.frame.size.width / 2), y: 0 - 100 + 60)
       
       moveObstacleStar = SKAction.moveBy(x: distance, y:  CGFloat(randY * 100), duration: TimeInterval(0.03 * distance))
               
    
       moveAndRemoveStar = SKAction.sequence([moveObstacleStar,removeObstacle])
       
       
       
       rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.25)
       repeatRotation = SKAction.repeatForever(rotateClock)
       
       throwingStar.run(repeatRotation)
       throwingStar1.run(repeatRotation)
       
       throwingStar.run(imPulseAction)
       throwingStar1.run(imPulseAction)
       
       
       obstaclePairStar.addChild(throwingStar)
       obstaclePairStar.addChild(throwingStar1)
       
       obstaclePairStar.zPosition = 1
       obstaclePairStar.run(moveAndRemoveStar)
       
       self.addChild(obstaclePairStar)
       
   }
    
    
    //Second obstacle creation method
    func createHedge(){
        
        randY4 = Int.random(in: -25..<0)
        
        
        
        let distance = CGFloat(self.frame.size.width * 2)
        
        
        let moveObstacle4 = SKAction.moveBy(x: -distance, y:  CGFloat(randY4 * 100), duration: TimeInterval(0.03 * distance))
        
        let removeObstacle4 = SKAction.removeFromParent()
        
        moveAndRemove4 = SKAction.sequence([moveObstacle4,removeObstacle4])
        
        let alternateStar = SKSpriteNode(imageNamed:"Obs3")
        
        
        alternateStar.size = CGSize(width: self.frame.size.width / 4, height: self.frame.size.width / 5)
        
        alternateStar.position=CGPoint(x: 0 + (self.frame.size.width / 2), y: 0 + (self.frame.size.height / 2) - (alternateStar.frame.size.height / 2)-200 + 60)
        
        alternateStar.physicsBody = SKPhysicsBody(circleOfRadius: alternateStar.frame.size.width / 2)
        alternateStar.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        alternateStar.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        alternateStar.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        alternateStar.physicsBody?.isDynamic = false
        alternateStar.physicsBody?.affectedByGravity = false
        alternateStar.zRotation = CGFloat(Double.pi)
        alternateStar.zPosition = 1
    
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        alternateStar.run(repeatRotation)
        
        alternateStar.run(imPulseAction)
        alternateStar.run(moveAndRemove4)
        
        self.addChild(alternateStar)
        
    }
    
    //Second obstacle creation method
    func createHedge1(){
 
        randY4 = Int.random(in: 5..<25)

        let distance = CGFloat(self.frame.width * 2)
        
        let moveObstacleHedge = SKAction.moveBy(x: distance, y:  CGFloat(randY4 * 100), duration: TimeInterval(0.03 * distance))
        
        let removeObstacle4 = SKAction.removeFromParent()
        
        moveAndRemove4 = SKAction.sequence([moveObstacleHedge,removeObstacle4])
        
        let alternateStar = SKSpriteNode(imageNamed:"Obs3")
        
        
        alternateStar.size = CGSize(width: self.frame.size.width / 4, height: self.frame.size.width / 5)

        
        alternateStar.position=CGPoint(x: 0 - (self.frame.size.width / 2), y: 0 - (self.frame.size.height / 2) - (alternateStar.frame.size.height / 2)-200 + 60)
        
        alternateStar.physicsBody = SKPhysicsBody(circleOfRadius: alternateStar.frame.size.width / 2)
        alternateStar.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        alternateStar.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        alternateStar.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        alternateStar.physicsBody?.isDynamic = false
        alternateStar.physicsBody?.affectedByGravity = false
        alternateStar.zRotation = CGFloat(Double.pi)
        alternateStar.zPosition = 1
    
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        alternateStar.run(repeatRotation)
        
        alternateStar.run(imPulseAction)
        alternateStar.run(moveAndRemove4)
        
        self.addChild(alternateStar)
        
    }
    
    
    //First obstacle creation method
    func createObstacle1(){
        obstaclePair = SKNode()
        obstaclePair.name = "obstaclePair"
        
        let distance = CGFloat(self.frame.size.width / 4)
        
        let sawLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        let sawLabel1 = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        
        sawLabel.fontSize = 75
        sawLabel.fontColor = SKColor.white
        sawLabel.position = CGPoint(x: self.frame.midX, y: 0 + (background.size.height / 2) - (CGFloat(distance) / 2) - 50)
        sawLabel.zPosition=1
        
        sawLabel1.text = "!"
        
        sawLabel1.fontSize = 75
        sawLabel1.fontColor = SKColor.white
        sawLabel1.position = CGPoint(x: self.frame.midX, y: 0 - (background.size.height / 2) + (CGFloat(distance) / 2))
        sawLabel1.zPosition=1
        sawLabel.text = "!"
        
        let inOut = SKAction.sequence([(SKAction.fadeIn(withDuration: 0.5)), (SKAction.fadeOut(withDuration: 0.5))])
        let rinOut = SKAction.repeat(inOut, count: 5)
                
        let moveObstacleUp = SKAction.moveBy(x: 0, y: distance, duration: TimeInterval(0.02 * distance))
        let moveObstacleDown = SKAction.moveBy(x: 0, y: -distance, duration: TimeInterval(0.02 * distance))
        
        let removeObstacle = SKAction.removeFromParent()
        
        let moveUAndRemove = SKAction.sequence([SKAction.wait(forDuration: 2.5), moveObstacleUp,moveObstacleDown,removeObstacle])
        let moveDAndRemove = SKAction.sequence([SKAction.wait(forDuration: 2.5), moveObstacleDown,moveObstacleUp,removeObstacle])
               
        
       
        let displayRemove = SKAction.sequence([rinOut,removeObstacle])
        
        let randomX = Int.random(in: -50..<50)
        
        let obstacle3 = SKSpriteNode(imageNamed:"Saw")
        let obstacle4 = SKSpriteNode(imageNamed:"Saw")
        
        obstacle3.size = CGSize(width: self.frame.size.width, height: self.frame.size.width)
        
        obstacle3.position=CGPoint(x: self.frame.midX, y: self.frame.midY - (self.frame.size.height / 2) - (obstacle3.size.height / 2))
        
        obstacle3.physicsBody = SKPhysicsBody(circleOfRadius: obstacle3.size.height / 2)
        obstacle3.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        obstacle3.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle3.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle3.physicsBody?.isDynamic = false
        obstacle3.physicsBody?.affectedByGravity = false
        obstacle3.zRotation = CGFloat(Double.pi)
        
        obstacle4.size = CGSize(width: self.frame.size.width, height: self.frame.size.width)
        
        obstacle4.position=CGPoint(x: self.frame.midX, y: self.frame.midY + (self.frame.size.height / 2) + (obstacle4.size.height / 2))
        
        obstacle4.physicsBody = SKPhysicsBody(circleOfRadius: obstacle4.size.height / 2)
        obstacle4.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        obstacle4.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle4.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle4.physicsBody?.isDynamic = false
        obstacle4.physicsBody?.affectedByGravity = false
        
        
        obstacle3.zPosition = 1
        obstacle4.zPosition = 1
        
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.25)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        obstacle3.run(repeatRotation)
        obstacle4.run(repeatRotation)
        
        sawLabel.run(displayRemove)
        sawLabel1.run(displayRemove)
        
        obstacle3.run(moveUAndRemove)
        obstacle4.run(moveDAndRemove)
        
        self.addChild(sawLabel)
        self.addChild(sawLabel1)
        self.addChild(obstacle3)
        self.addChild(obstacle4)
        
        
    }
    
    func createObstacle3(){
        let distance = CGFloat(self.frame.size.width + 50)
        
        if negGravity == true {
            randY3 = Int.random(in: 0..<300)
        }else{
            randY3 = Int.random(in: -300..<0)
        }
        let moveObstacle = SKAction.moveBy(x: -distance, y:  0, duration: TimeInterval(0.05 * distance))
        
        let removeObstacle = SKAction.removeFromParent()
        
        let moveAndRemove = SKAction.sequence([moveObstacle,removeObstacle])
        
        let liteSaber = SKSpriteNode(imageNamed:"litesaber")
        
        
        liteSaber.size = CGSize(width: self.frame.size.width / 50, height: self.frame.width / 2 + 25)
        
        liteSaber.position=CGPoint(x: 0 + (self.frame.size.width / 2), y: 0)
        liteSaber.physicsBody = SKPhysicsBody(rectangleOf: liteSaber.frame.size)
        liteSaber.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        liteSaber.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        liteSaber.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        liteSaber.physicsBody?.isDynamic = false
        liteSaber.physicsBody?.affectedByGravity = false
        liteSaber.zRotation = CGFloat(Double.pi)
        
        rotateClockSaber1 = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5)
        repeatRotation = SKAction.repeatForever(rotateClockSaber1)
        
        
        
        liteSaber.run(repeatRotation)
       
        
        liteSaber.zPosition = 1
        liteSaber.run(moveAndRemove)
        
        self.addChild(liteSaber)
    }
    
    func addScoreAndSubmitToGC(scoreVal:Int64){
        
        let bestScoreInt = GKScore(leaderboardIdentifier: "com.leytontaylor.gravityswitch.leaderboard")
        bestScoreInt.value = scoreVal
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.gameStarted == true {
            if !self.died {
                if(self.scoreStarted){
                    self.scoreVal+=1
                    self.scoreLabel.text = String(scoreVal)
                    if self.scoreVal == 10 {
                        gameLevel = 1
                    }else if self.scoreVal == 1000 {
                        levelReached = false
                        gameLevel = 2
                    }else if self.scoreVal == 1500 {
                        levelReached = false
                        gameLevel = 3
                    }else if self.scoreVal == 2000 {
                        levelReached = false
                        gameLevel = 4
                    }
                    
                    if self.scoreVal % 500 == 0{
                        
                    }
                }
            }
        }
    }
}
