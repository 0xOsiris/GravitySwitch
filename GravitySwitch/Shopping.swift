//
//  Shopping.swift
//  RetroRoute
//
//  Created by Leyton Taylor on 4/23/20.
//  Copyright © 2020 Leyton Taylor. All rights reserved.
//

import SpriteKit

class Shopping: SKScene {
    
    var bgCart = SKSpriteNode()
    var exitButton = SKSpriteNode()
    //Main menu screen method. Called when app initially starts
    //and when main menu button is clicked
    func loadCart(){
        //Declare background attributes
        exitButton = SKSpriteNode()
        exitButton.size = CGSize(width: 100, height:100)
        exitButton.position = CGPoint(x: 279,y:556)
        
        exitButton.zPosition = 3
        self.addChild(exitButton)
        
    }
    //Initially calls mainMenu() when Application is started
    override func didMove(to view: SKView) {
        print("Howdy")
        loadCart()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Howdy")
        for touch in touches{
            let location = touch.location(in:self)
            
            
            if exitButton.contains(_:location){
                loadMain()
            }
            
            
        }
        
    }
    
    func loadMain(){
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

    

    

}
