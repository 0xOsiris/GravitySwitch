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


//Declaration of Physics Categories
struct PhysicsCategory {
    static let Main : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Obstacle : UInt32 = 0x1 << 3
    static let Ceiling : UInt32 = 0x1 << 4
    
}

protocol GameSceneDelegate {
    func died()
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    var moveObstacle1 = SKAction()
    //sequence actions used for spawning obstacles
    var moveAndRemove = SKAction()
    var moveAndRemove1 = SKAction()
    //SKAction for rotation
    var repeatRotation = SKAction()
    //Clockwise and counter clockwise rotation SKActions
    var rotateClock = SKAction()
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
    
    //Initial text displayed on screen
    let taptoPlay = SKLabelNode(fontNamed: "Chalkduster")
    //Label to keep track of score
    var scoreLabel = SKLabelNode(fontNamed: "PingFang TC")
    
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
    
    var gameCenterDelegate : GameSceneDelegate?
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
    
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        self.died = false
        self.gamePaused = false
        gameStarted = false
        negGravity = false
        background=SKSpriteNode(imageNamed:"TileBG")
        background.name = "background"
        background.size.height = self.frame.height
        background.size.width=self.frame.width
        self.addChild(background)
        createScene()
        
    }
    
    
    //Main menu screen method. Called when app initially starts
    //and when main menu button is clicked
    func mainMenu(){
        self.removeAllChildren()
        
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MainMenu(fileNamed:"MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
    }
    
    
    
    //Takes to main menu screen
    func resetMain(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        negGravity=false
        mainMenu()
                
    }
    
    // Show Pause Alert
    func showPauseAlert() {
        self.gamePaused = true
        var alert = UIAlertController(title: "Pause", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default)  { _ in
            self.gamePaused = false
            })
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    //Called each time the gameplay is started
    //Attaches all of the sprite nodes to the parent view
    func createScene(){
        self.physicsWorld.contactDelegate = self
        
        //Background declaration
        background = SKSpriteNode(imageNamed: "TileBG")
        background.name = "background"
        background.size.height = self.frame.height
        background.size.width=self.frame.width
        
        scoreVal = 0
        scoreLabel.text = "Score:" + String(scoreVal)
        
        scoreLabel.fontSize = 65
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
        
        
        gravityBar1.position = CGPoint(x: 0, y: ((self.size.height / 2) - self.size.height / 21) - (gravityBar1.size.height / 2))
        antiGravityBar1.size.width = self.size.width
        antiGravityBar1.size.height = self.size.height
        antiGravityBar1.position = CGPoint(x: 0, y: ((self.size.height / 2) +  (gravityBar1.size.height / 2)))
        
        
        gravityBar1.zPosition = -2
        antiGravityBar1.zPosition = -1
        
        //Declaration of Ground object
        Ground = SKSpriteNode(color: .clear, size: CGSize(width: self.size.width, height: self.size.height / 21))
        Ground.position=CGPoint(x: 0, y: 0 - (self.frame.height / 2) + (Ground.frame.height / 2))
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        
        
        //Declaration of Ceiling object
        Ceiling = SKSpriteNode(color: .clear, size: CGSize(width: self.size.width, height: self.size.height / 21))
        Ceiling.position=CGPoint(x: 0, y: 0 + (self.frame.height / 2) - (Ceiling.frame.height / 2))
        Ceiling.physicsBody = SKPhysicsBody(rectangleOf: Ceiling.size)
        Ceiling.physicsBody?.categoryBitMask = PhysicsCategory.Ceiling
        Ceiling.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Obstacle
        Ceiling.physicsBody?.affectedByGravity = false
        Ceiling.physicsBody?.isDynamic = false
        
        
        //Declaration of main character Main
        Main = SKSpriteNode(imageNamed: "sprite")
        Main.setScale(0.08)
        Main.position=CGPoint(x: 0, y: 0)
        Main.physicsBody = SKPhysicsBody(circleOfRadius: Main.frame.height / 2 - 5)
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
        restartBTN.size = CGSize(width: 450, height: 450)
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    
    //Creates settings button constituents
    func createSettingsButton(){
        settingsButton = SKSpriteNode(imageNamed: "Restart")
        settingsButton.size = CGSize(width: 450, height: 450)
        settingsButton.position = CGPoint(x: 0, y: 0)
        settingsButton.zPosition = 6
        settingsButton.setScale(0)
        self.addChild(settingsButton)
        settingsButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    
    //Initially calls mainMenu() when Application is started
    override func didMove(to view: SKView) {
        createScene()
        
    }
    
    func showGameOverAlert() {
        self.gamePaused = true
        var alert = UIAlertController(title: "Game Over", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)  { _ in
            
            
            // reset score
            self.addLeaderboardScore(scoreVal: self.scoreVal)
            self.scoreVal=0
            self.scoreLabel.text = String(0)
            
        })
        
        // show alert
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
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
                if !self.gamePaused {
                    self.gamePaused = true
                    self.died = true
                    createRestartBTN()
                    showGameOverAlert()
                }
                
            }
        }
        
        
    }
    
    //Negates gravity changes background color and Moves Main
    //To Ceiling
    @objc func swipedUp() {
        negGravity = true
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 10)
        moveUp = SKAction.move(to : CGPoint(x: 0, y:0 + (self.frame.height / 2) - (Ceiling.frame.height) - (Main.frame.height / 2)),duration: TimeInterval(0.25))
        moveGravUp = SKAction.move(to : CGPoint(x: 0, y:0),duration: TimeInterval(0.5))
        antiGravityBar1.run(moveGravUp)
        Main.run(moveUp)
        print("Up")
        
        
    }
    
    //Negates gravity, changes background color to blue and Moves Main to bottom of screen
    @objc func swipedDown() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        
        moveDown = SKAction.move(to : CGPoint(x: 0, y:0 - (self.frame.height / 2) + (Ceiling.frame.height) + (Main.frame.height / 2)),duration: TimeInterval(0.25))
        
        moveGravDown = SKAction.move(to : CGPoint(x: 0, y:0 - (self.frame.height / 2) - (antiGravityBar1.frame.height / 2)),duration: TimeInterval(0.5))
        
        antiGravityBar1.run(moveGravDown)
        
        Main.run(moveDown)
        negGravity = false
        print("Down")
        
        
    }
    
   
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        taptoPlay.text=""
        
        
        let delay = SKAction.wait(forDuration: 3, withRange: 2)
        let delay1 = SKAction.wait(forDuration: 3, withRange: 2)
        
        
        if gameStarted == false{
                
            gameStarted = true
            
            let spawn = SKAction.run({
                () in
        
                self.createObstacle1()
                
            })
            
            let spawn1 = SKAction.run({
                () in
                
                self.createObstacle2()
                
            })
            
            let spawn2 = SKAction.run({
                () in
                
                self.createObstacle3()
            })
            
            var actions = Array<SKAction>()
            
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            let SpawnDelay1 = SKAction.sequence([spawn1, delay1])
            let spawnDelayForever1 = SKAction.repeatForever(SpawnDelay1)
            let SpawnDelay2 = SKAction.sequence([spawn2, delay])
            let spawnDelayForever2 = SKAction.repeatForever(SpawnDelay2)
            
            actions.append(spawnDelayForever)
            actions.append(spawnDelayForever1)
            actions.append(spawnDelayForever2)
            
            let spawnGroup = SKAction.sequence([SpawnDelay, SpawnDelay1,SpawnDelay2])
            let spawnGroupForever = SKAction.repeatForever(spawnGroup)
            
            self.run(spawnGroupForever)
            
            if negGravity == false{
                
                Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                Main.physicsBody?.applyImpulse(CGVector(dx : 0,dy : 100))
                rotateCounter = SKAction.rotate(byAngle: CGFloat.pi *  -2, duration: 1)
                repeatRotation = SKAction.repeatForever(rotateCounter)
                Main.run(repeatRotation)
                
            }else{
                rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
                repeatRotation = SKAction.repeatForever(rotateClock)
                Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                Main.physicsBody?.applyImpulse(CGVector(dx : 0,dy : -100))
                Main.run(repeatRotation)
            }
            
        }else{
            if self.died == true{
                
            }else{
                if negGravity == false{
                    Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                    Main.physicsBody?.applyImpulse(CGVector(dx : 0,dy : 100))
                    rotateCounter = SKAction.rotate(byAngle: CGFloat.pi *  -2, duration: 1)
                    repeatRotation = SKAction.repeatForever(rotateCounter)
                    Main.run(repeatRotation)
                }else{
                    rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
                    repeatRotation = SKAction.repeatForever(rotateClock)
                    Main.physicsBody?.velocity = CGVector(dx : 0, dy : 0)
                    Main.physicsBody?.applyImpulse(CGVector(dx : 0,dy : -100))
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
    func createObstacle2(){
        obstaclePair1 = SKNode()
        obstaclePair1.name = "obstaclePair1"
        
        let randImpulse = Int.random(in: 0..<100)
        let randY = Int.random(in: -20..<20)
        
        let distance = CGFloat(self.frame.width * 2)
        
        
        let moveObstacle1 = SKAction.moveBy(x: -distance - CGFloat(randImpulse), y:  CGFloat(randY * 100), duration: TimeInterval(0.01 * distance))
        
        let removeObstacle = SKAction.removeFromParent()
        
        moveAndRemove1 = SKAction.sequence([moveObstacle1,removeObstacle])
        
        let throwingStar = SKSpriteNode(imageNamed:"ThrowingStar")
        let throwingStar1 = SKSpriteNode(imageNamed:"ThrowingStar")
        
        throwingStar.setScale(0.15)
        throwingStar1.setScale(0.15)
        
        throwingStar.position=CGPoint(x: 0 + (self.frame.width / 2), y: 0 + (self.frame.height / 2) - (throwingStar.frame.height / 2)-200)
        
        throwingStar.physicsBody = SKPhysicsBody(circleOfRadius: throwingStar.frame.width / 2)
        throwingStar.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        throwingStar.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar.physicsBody?.isDynamic = false
        throwingStar.physicsBody?.affectedByGravity = false
        throwingStar.zRotation = CGFloat(Double.pi)
        
        throwingStar1.position=CGPoint(x: 0 + self.frame.width / 2 + 700, y: 0 - 100)
        
        throwingStar1.physicsBody = SKPhysicsBody(circleOfRadius: throwingStar1.frame.width / 2)
        throwingStar1.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        throwingStar1.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar1.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        throwingStar1.physicsBody?.isDynamic = false
        throwingStar1.physicsBody?.affectedByGravity = false
        
        throwingStar1.zRotation = CGFloat(Double.pi)
        
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        throwingStar.run(repeatRotation)
        throwingStar1.run(repeatRotation)
        
        throwingStar.run(imPulseAction)
        throwingStar1.run(imPulseAction)
        
        
        obstaclePair1.addChild(throwingStar)
        obstaclePair1.addChild(throwingStar1)
        
        obstaclePair1.zPosition = 1
        obstaclePair1.run(moveAndRemove1)
        
        self.addChild(obstaclePair1)
        
    }
    
    
    //First obstacle creation method
    func createObstacle1(){
        
        obstaclePair = SKNode()
        obstaclePair.name = "obstaclePair"
 
        let distance = CGFloat(self.frame.width / 4)
        
        let randomX = Int.random(in: -50..<50)
        
        let moveObstacleUp = SKAction.moveBy(x: 0, y: distance, duration: TimeInterval(0.01 * distance))
        let moveObstacleDown = SKAction.moveBy(x: 0, y: -distance, duration: TimeInterval(0.01 * distance))
        let removeObstacle = SKAction.removeFromParent()
        
        let moveUAndRemove = SKAction.sequence([moveObstacleUp,moveObstacleDown,removeObstacle])
        let moveDAndRemove = SKAction.sequence([moveObstacleDown,moveObstacleUp,removeObstacle])
        
        let obstacle3 = SKSpriteNode(imageNamed:"Tazer")
        let obstacle4 = SKSpriteNode(imageNamed:"Tazer")
        
        let randScale = CGFloat(Int.random(in: 3...6))
        
        
        obstacle3.size.height = self.frame.height / randScale
        
        obstacle3.position=CGPoint(x: 0 + CGFloat(randomX), y: 0 - (self.frame.height / 2) - (obstacle3.frame.height / 2))
        
        obstacle3.physicsBody = SKPhysicsBody(rectangleOf: obstacle3.frame.size)
        obstacle3.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        obstacle3.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle3.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle3.physicsBody?.isDynamic = false
        obstacle3.physicsBody?.affectedByGravity = false
        obstacle3.zRotation = CGFloat(Double.pi)
        
        obstacle4.size.height = self.frame.height / randScale
        
        obstacle4.position=CGPoint(x: 0 + CGFloat(randomX), y: 0 + (self.frame.height / 2) + (obstacle4.frame.height / 2))
        
        obstacle4.physicsBody = SKPhysicsBody(rectangleOf: obstacle4.frame.size)
        obstacle4.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        obstacle4.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle4.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        obstacle4.physicsBody?.isDynamic = false
        obstacle4.physicsBody?.affectedByGravity = false
        
        
        obstacle3.zPosition = 1
        obstacle4.zPosition = 1
        
        obstacle3.run(moveUAndRemove)
        obstacle4.run(moveDAndRemove)
        
        self.addChild(obstacle3)
        self.addChild(obstacle4)
        
        
    }
    
    func createObstacle3(){
        
        let randImpulse = Int.random(in: -50..<50)
        
        let distance = CGFloat(self.frame.width * 2)
        
        let moveObstacle = SKAction.moveBy(x: -distance - CGFloat(randImpulse), y:  100 * CGFloat(randImpulse), duration: TimeInterval(0.01 * distance))
        
        let removeObstacle = SKAction.removeFromParent()
        
        let moveAndRemove = SKAction.sequence([moveObstacle,removeObstacle])
        
        let liteSaber = SKSpriteNode(imageNamed:"litesaber")
        
        
        liteSaber.setScale(0.4)
        
        liteSaber.position=CGPoint(x: 0 + (self.frame.width / 2), y: 0)
        liteSaber.physicsBody = SKPhysicsBody(circleOfRadius: liteSaber.frame.height / 2)
        liteSaber.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        liteSaber.physicsBody?.collisionBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        liteSaber.physicsBody?.contactTestBitMask = PhysicsCategory.Main | PhysicsCategory.Ceiling | PhysicsCategory.Ground
        liteSaber.physicsBody?.isDynamic = false
        liteSaber.physicsBody?.affectedByGravity = false
        liteSaber.zRotation = CGFloat(Double.pi)
        
        
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.25)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        liteSaber.run(repeatRotation)
        liteSaber.run(imPulseAction)
        
        liteSaber.zPosition = 1
        liteSaber.run(moveAndRemove)
        
        self.addChild(liteSaber)
    }
    
    func addLeaderboardScore(scoreVal:Int64) {
        var newGCScore = GKScore(leaderboardIdentifier: "com.leytontaylor.gravityswitch.leaderboard")
        newGCScore.value = scoreVal
        GKScore.report([newGCScore], withCompletionHandler: {(error) -> Void in
            if error != nil {
                print("Score not submitted")
                // Continue
                self.died = false
            } else {
                // Notify the delegate to show the game center leaderboard
                self.gameCenterDelegate!.died()
            }
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !self.gamePaused && !self.died {
            self.scoreVal+=1
            self.scoreLabel.text = String(scoreVal)
        }
    }
}
