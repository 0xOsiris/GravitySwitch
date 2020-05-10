//
//  GameViewController.swift
//  RetroRoute
//
//  Created by Leyton Taylor on 4/5/20.
//  Copyright © 2020 Leyton Taylor. All rights reserved.
//

import UIKit
import SpriteKit

import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GameSceneDelegate {

    
    var scene : GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authenticateUser()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a fullscreen Scene object
        scene = GameScene(fileNamed:"GameScene")
        scene!.scaleMode = .aspectFill
        scene!.gameCenterDelegate=self
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        skView.presentScene(scene)
    }
    
    
    private func authenticateUser(){
        let player = GKLocalPlayer.local
        
        player.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            if let vc = vc {
                self.scene!.gamePaused = true
                self.present(vc, animated: true,
                             completion: nil)
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector:Selector(("gameCenterStateChanged")), name: NSNotification.Name(rawValue: "GKPlayerAuthenticationDidChangeNotificationName"), object: nil)
            }
        }
    }
    
    
    // Continue the Game, if GameCenter Authentication state
    // has been changed (login dialog is closed)
    func gameCenterStateChanged() {
        self.scene!.gamePaused = false
    }
    
    func died() {
        
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = "com.leytontaylor.gravityswitch.leaderboard"
        
        // Show leaderboard
        self.present(gcViewController, animated: true, completion: nil)
    }
    
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        scene!.died = false
    }
    
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
