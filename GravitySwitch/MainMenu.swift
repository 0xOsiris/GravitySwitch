//
//  MainMenu.swift
//  RetroRoute
//
//  Created by Leyton Taylor on 5/5/20.
//  Copyright © 2020 Leyton Taylor. All rights reserved.
//

import SpriteKit
import GameKit
import GameplayKit

class MainMenu: SKScene{
    
    
    //Initial text displayed on screen
    let taptoPlay = SKLabelNode(fontNamed: "Chalkduster")
    
    var repeatRotation = SKAction()
    //Clockwise and counter clockwise rotation SKActions
    var rotateClock = SKAction()
    
    var restartBTN = SKSpriteNode()
    //Settings button on main menu
    var settingsButton = SKSpriteNode()
    //ShopButton on main menu
    var shopButton = SKSpriteNode()
    //Background SKPriteNodce() object---changes image between gameplay and mainmenu screeen
    var backgroundMain = SKSpriteNode()
    var backgroundSprite = SKSpriteNode()
    
    
    //Main menu screen method. Called when app initially starts
    //and when main menu button is clicked
    func mainMenu(){

        shopButton.size = CGSize(width: 95, height: 95)
        shopButton.position = CGPoint(x: 5, y: -345)
        
        shopButton.zPosition = 2
        

        settingsButton.size = CGSize(width: 95, height: 95)
        settingsButton.position = CGPoint(x: -258, y: -170)
        
        settingsButton.zPosition = 2
        
        
        //Declare background attributes
        backgroundMain = SKSpriteNode(imageNamed: "main")
        backgroundMain.name = "background"
        backgroundMain.size.height = self.frame.height
        backgroundMain.size.width=self.frame.width
        backgroundSprite = SKSpriteNode(imageNamed: "sprite")
        backgroundSprite.setScale(0.1)
        backgroundSprite.position=CGPoint(x: 0, y: -(self.frame.height / 2)+(self.frame.height / 12)*5 - 50)
        //backgroundSprite.physicsBody = SKPhysicsBody(circleOfRadius: Main.frame.height / 2 - 5)
        
        backgroundSprite.physicsBody?.affectedByGravity = false
        backgroundSprite.physicsBody?.isDynamic = false
        backgroundSprite.zPosition=2
        
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        backgroundSprite.run(repeatRotation)
        
        taptoPlay.text = "Tap to Play"
        taptoPlay.fontSize = 65
        taptoPlay.fontColor = SKColor.white
        taptoPlay.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        taptoPlay.zPosition=1
        
        let fadeInOut = SKAction.sequence([(SKAction.fadeIn(withDuration: 1.5)), (SKAction.fadeOut(withDuration: 1.5))])
        let repeatFade = SKAction.repeatForever(fadeInOut)
        
        taptoPlay.run(repeatFade)
        
        self.addChild(settingsButton)
        self.addChild(shopButton)
        self.addChild(taptoPlay)
        self.addChild(backgroundMain)
        self.addChild(backgroundSprite)
    }
    
    //Initially calls mainMenu() when Application is started
    override func didMove(to view: SKView) {
        
        mainMenu()
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in:self)
            
            
            if settingsButton.contains(_:location){
                loadSettings()
            }else if shopButton.contains(_:location) {
                loadShop()
            }else{
                loadGame()
                    
            }
            
        }
        
    }
    
    func loadSettings(){
        self.removeAllChildren()
        
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed:"Settings") {
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
    
    func loadShop(){
        self.removeAllChildren()
        
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed:"Shopping") {
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
    
    func loadGame() {
        self.removeAllChildren()
        
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed:"GameScene") {
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

        

    override func update(_ currentTime: TimeInterval) {
        
    }
}
