//
//  Settings.swift
//  RetroRoute
//
//  Created by Leyton Taylor on 5/5/20.
//  Copyright © 2020 Leyton Taylor. All rights reserved.
//

import SpriteKit

class Settings: SKScene{
    var exitSetting = SKSpriteNode()
    var muteLabel = SKSpriteNode()
    var creditsLabel = SKSpriteNode()
    var privacyLabel = SKSpriteNode()
    var backgroundSetting = SKSpriteNode()
    var mute = SKLabelNode()
    var privacy = SKLabelNode()
    var credits = SKLabelNode()
    
    var blueBG = SKSpriteNode()
    
    func loadSetting(){
        credits = self.childNode(withName: "credits") as! SKLabelNode
        privacy = self.childNode(withName: "privacy") as! SKLabelNode
        mute = self.childNode(withName: "mute") as! SKLabelNode
        
        blueBG = self.childNode(withName: "blueBG") as! SKSpriteNode
        blueBG.texture = SKTexture(imageNamed: "Settingsbg")
        
        backgroundSetting = self.childNode(withName: "background") as! SKSpriteNode
        backgroundSetting.texture = SKTexture(imageNamed: "mainmenu-1")
        
        exitSetting = self.childNode(withName: "exitSetting") as! SKSpriteNode
        exitSetting.texture = SKTexture(imageNamed: "xButton")
        
        muteLabel = self.childNode(withName: "muteLabel") as! SKSpriteNode
        muteLabel.texture = SKTexture(imageNamed: "SettingsLabel")
        
        creditsLabel = self.childNode(withName: "creditsLabel") as! SKSpriteNode
        creditsLabel.texture = SKTexture(imageNamed: "SettingsLabel")
        
        privacyLabel = self.childNode(withName: "privacyLabel") as! SKSpriteNode
        privacyLabel.texture = SKTexture(imageNamed: "SettingsLabel")
        
        
        
        
    }
    //Initially calls mainMenu() when Application is started
    override func didMove(to view: SKView) {
        
        loadSetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let location = touch.location(in:self)
            
            
            if exitSetting.contains(_:location){
                loadMain()
            }
            
            
        }
        
    }
    
    func loadMain(){
        
        
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
}
