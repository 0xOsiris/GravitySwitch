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
import StoreKit

protocol GameSceneDelegate{
    func showLeaderboard()
}


class MainMenu: SKScene{
    var product: SKProduct?
    var productId = "RemoveAd"
    
    var viewController: GameViewController!
    var gameCenterDelegate : GameSceneDelegate?
    
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
    //Game Center Leaderboard
    var showLeaderboard = SKSpriteNode()
    var removeAds = SKSpriteNode()
    //Background SKPriteNodce() object---changes image between gameplay and mainmenu screeen
    var backgroundMain = SKSpriteNode()
    var backgroundSprite = SKSpriteNode()
    var adAnimation = SKSpriteNode()
    var titleBG = SKSpriteNode()
    var banner = SKShapeNode()
    var highScoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var highScoreDefault = 0
    //Main menu screen method. Called when app initially starts
    //and when main menu button is clicked
    func mainMenu(){
        if(UserDefaults.standard.integer(forKey: "HighScore") > highScoreDefault){
            highScoreDefault = UserDefaults.standard.integer(forKey: "HighScore")
            
        }
 
        //Declare background attributes
        backgroundMain = self.childNode(withName: "backgroundMain") as! SKSpriteNode
        
        
        backgroundMain.texture = SKTexture(imageNamed: "mainmenuFinal")
        
        backgroundMain.size.height = self.frame.size.height
        backgroundMain.size.width = self.frame.size.width
        backgroundMain.position = CGPoint(x: 0, y: 0)
        highScoreLabel = self.childNode(withName: "highScore") as! SKLabelNode
        highScoreLabel.text = String(highScoreDefault)
        highScoreLabel.position = CGPoint(x: self.frame.midX, y: 0 - self.frame.size.height / 20)
        highScoreLabel.fontSize = 25
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition=3
        
        titleBG = self.childNode(withName: "titleBG") as! SKSpriteNode
        titleBG.size.height = self.frame.size.height / 4
        titleBG.size.width = self.frame.size.width
        titleBG.position = CGPoint(x: 0, y: 0 + self.frame.size.height / 2 - titleBG.size.height / 2 - 40)
        
        
        
        
        removeAds = self.childNode(withName: "removeAds") as! SKSpriteNode
        removeAds.size.height = self.frame.size.height / 10
        removeAds.size.width = self.frame.size.width / 3
        removeAds.position = CGPoint(x: 0 - (self.frame.size.width / 2) + removeAds.frame.size.width / 2, y: 0 - self.frame.size.height / 20)
        
        
        adAnimation = self.childNode(withName: "adAnimation") as! SKSpriteNode
        adAnimation.size.height = self.frame.size.height / 20
        adAnimation.size.width = self.frame.size.height / 20
        
        adAnimation.position = CGPoint(x: 0 - (self.frame.size.width / 2) + removeAds.frame.size.width / 2, y: 0 - self.frame.size.height / 20 + adAnimation.frame.size.height / 4)
        //settingsButton = backgroundMain.childNode(withName: "settingsButton") as! SKSpriteNode
        showLeaderboard = self.childNode(withName: "showLeaderboard") as! SKSpriteNode
        showLeaderboard.size.height = self.frame.size.height / 10
        showLeaderboard.size.width = self.frame.size.width / 3
        showLeaderboard.position = CGPoint(x: 0 - (self.frame.size.width / 2) + removeAds.frame.size.width / 2, y: 0 - self.frame.size.height / 20 - showLeaderboard.frame.size.height)
        
        backgroundSprite = self.childNode(withName: "bgSprite") as! SKSpriteNode
        
        backgroundSprite.texture = SKTexture(imageNamed: "spritemain")
        backgroundSprite.size.height = self.frame.size.height / 10
        backgroundSprite.size.width = self.frame.size.height / 10
        
        titleBG.texture = SKTexture(imageNamed: "GravitySwitchTitle")
        adAnimation.texture = SKTexture(imageNamed: "RemoveAdLog")
        adAnimation.zPosition = 3
        titleBG.zPosition = 2
        showLeaderboard.texture = SKTexture(imageNamed: "Leaderboard")
        //settingsButton.texture = SKTexture(imageNamed: "settingsMain")
        removeAds.texture = SKTexture(imageNamed: "RemoveAds")
        //settingsButton.zPosition = 2
        removeAds.zPosition = 2
        showLeaderboard.zPosition = 2
        
        backgroundSprite.physicsBody?.affectedByGravity = false
        backgroundSprite.physicsBody?.isDynamic = false
        backgroundSprite.zPosition=3
        
        rotateClock = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
        repeatRotation = SKAction.repeatForever(rotateClock)
        
        let rotateClockFast = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5)
        let repeatDelay = SKAction.sequence([rotateClockFast,SKAction.wait(forDuration: 3.0)])
        let repeatDelay1 = SKAction.sequence([rotateClockFast,SKAction.wait(forDuration: 5.0)])
        
        let repeatDelayForever = SKAction.repeatForever(repeatDelay)
        let repeatDelayForever1 = SKAction.repeatForever(repeatDelay1)
        
        adAnimation.run(repeatDelayForever)
        backgroundSprite.run(repeatDelayForever1)
        
        taptoPlay.text = "Tap to Play"
        taptoPlay.fontSize = 30
        taptoPlay.fontColor = SKColor.white
        taptoPlay.position = CGPoint(x: 0 - self.frame.midX, y: 0 + self.frame.size.height / 15)
        taptoPlay.zPosition=3
        
        
        let scaleDownUp = SKAction.sequence([SKAction.scale(to: CGSize(width: removeAds.frame.size.width - 5, height: removeAds.frame.size.height - 5), duration: 1.0),SKAction.scale(to: CGSize(width: removeAds.frame.size.width + 5, height: removeAds.frame.size.height + 5), duration: 1.0)])
        
        let scaleDownUpS = SKAction.sequence([SKAction.scale(to: CGSize(width: backgroundSprite.frame.size.width - 5, height: backgroundSprite.frame.size.height - 5), duration: 1.0),SKAction.scale(to: CGSize(width: backgroundSprite.frame.size.width + 5, height: backgroundSprite.frame.size.height + 5), duration: 1.0)])
        
        let repeatScale = SKAction.repeatForever(scaleDownUp)
        
        
        let repeatScaleS = SKAction.repeatForever(scaleDownUpS)
        backgroundSprite.run(repeatScaleS)
        removeAds.run(repeatScale)
        showLeaderboard.run(repeatScale)
        
        
        
        let fadeInOut = SKAction.sequence([(SKAction.fadeIn(withDuration: 1.5)), (SKAction.fadeOut(withDuration: 1.5))])
        let repeatFade = SKAction.repeatForever(fadeInOut)
        
        taptoPlay.run(repeatFade)
        
        
        self.addChild(taptoPlay)
        
    }
    
    //Initially calls mainMenu() when Application is started
    override func didMove(to view: SKView) {
        mainMenu()
        
    }
    
    
    func purchase(){
        
        viewController?.purchase()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            
            if removeAds.contains(_:location) {
                if(viewController?.setPurchaseEnabled() == true){
                    purchase()
                }
                
            }else if showLeaderboard.contains(_:location){
                loadLeaderboard()
                
            }else{
                loadGame()
            }
            
        }
        
    }
    
    
    
    func loadLeaderboard(){
        self.gameCenterDelegate?.showLeaderboard()
    }

    
    func loadGame() {
        self.removeAllChildren()
        
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed:"GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                scene.size = CGSize(width: view.bounds.size.width, height: view.bounds.size.height - 60)
                scene.viewController = self.viewController
                scene.interstitialDelegate = self.viewController
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            
        }
    }

        

    override func update(_ currentTime: TimeInterval) {
        
    }
}
