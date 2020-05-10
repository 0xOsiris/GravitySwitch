//
//  GameCenterManager.swift
//  GravitySwitch
//
//  Created by Leyton Taylor on 5/9/20.
//  Copyright © 2020 Leyton Taylor. All rights reserved.
//

import UIKit
import Foundation
import GameKit
class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    
    /// The local player object.
    let gameCenterPlayer = GKLocalPlayer.local
    /// player can use GameCenter
    var canUseGameCenter:Bool = false {
        didSet {
            /* load prev. achievments form Game Center */
            if canUseGameCenter == true { gameCenterLoadAchievements() }
        }}
    /// Achievements of player
    var gameCenterAchievements=[String:GKAchievement]()
    /// ViewController MainView
    var vc: UIViewController
    
    /**
        Constructor
    */
    init(rootViewController viewC: UIViewController) {
        self.vc = viewC
        super.init()
        loginToGameCenter()
    }
    
    /**
        Login to GameCenter
    */
    func loginToGameCenter() {
        self.gameCenterPlayer.authenticateHandler = {(gameCenterVC:UIViewController!, var gameCenterError:NSError!) -> Void in
            
            if gameCenterVC != nil {
                self.vc.presentViewController(gameCenterVC, animated: true, completion: { () -> Void in
                    
                })
            } else if self.gameCenterPlayer.authenticated == true {
                //self.self
                self.canUseGameCenter = true
            } else  {
                self.canUseGameCenter = false
            }
            
            if gameCenterError != nil {
                println("Game Center error: \(gameCenterError)")
            }
        }
    }
    /**
        Dismiss Game Center when player open
        :param: GKGameCenterViewController
    
        Override of GKGameCenterControllerDelegate
    */
    internal func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    /**
        Load achievement in cache
    */
    
    

    /**
        Add progress to an achievement
    
        :param: Progress achievement Double (ex: 10% = 10.00)
        :param: ID Achievement
    */
    func addProgressToAnAchievement(progress uProgress:Double,achievementIdentifier uAchievementId:String) {
        if canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenterAchievements[uAchievementId]
            
            if let achievement = lookupAchievement {
                if achievement.percentComplete != 100 {
                    achievement.percentComplete = uProgress
                    
                    if uProgress == 100.0  {
                        /* show banner only if achievement is fully granted (progress is 100%) */
                        achievement.showsCompletionBanner=true
                    }
                    
                    /* try to report the progress to the Game Center */
                    GKAchievement.report([achievement], withCompletionHandler:  {(error:Error!) -> Void in
                        if error != nil {
                            print("Couldn't save achievement (\(uAchievementId)) progress to \(uProgress) %")
                        }
                    })
                }
                /* Is Finish */
            } else {
                /* never added  progress for this achievement, create achievement now, recall to add progress */
                print("No achievement with ID (\(uAchievementId)) was found, no progress for this one was recoreded yet. Create achievement now.")
                gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                /* recursive recall this func now that the achievement exist */
                addProgressToAnAchievement(progress: uProgress, achievementIdentifier: uAchievementId)
            }
        }
    }
    /**
        Reports a given score to Game Center
    
        :param: the Score
        :param: leaderboard identifier
    */
    func reportScore(score uScore: Int,leaderboardIdentifier uleaderboardIdentifier: String ) {
        if canUseGameCenter == true {
            var scoreReporter = GKScore(leaderboardIdentifier: uleaderboardIdentifier)
            scoreReporter.value = Int64(uScore)
            var scoreArray: [GKScore] = [scoreReporter]
            GKScore.report(scoreArray, withCompletionHandler: {(error : Error!) -> Void in
                if error != nil {
                    NSLog(error.localizedDescription)
                }
            })
        }
    }
    /**
        Remove One Achievements
    
        :param: ID Achievement
    */
    func resetAchievements(achievementIdentifier uAchievementId:String) {
        if canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenterAchievements[uAchievementId]
            
            if let achievement = lookupAchievement {
                GKAchievement.resetAchievements(completionHandler: { (error:Error!) -> Void in
                    if error != nil {
                        print("Couldn't Reset achievement (\(uAchievementId))")
                    } else {
                        print("Reset achievement (\(uAchievementId))")
                    }
                })
                
            } else {
                print("No achievement with ID (\(uAchievementId)) was found, no progress for this one was recoreded yet. Create achievement now.")
                gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                /* recursive recall this func now that the achievement exist */
                self.resetAchievements(achievementIdentifier: uAchievementId)
            }
        }
    }
    /**
        Remove All Achievements
    */
    func resetAllAchievements() {
        if canUseGameCenter == true {
            
            for lookupAchievement in gameCenterAchievements {
                var achievementID = lookupAchievement.0
                var lookupAchievement:GKAchievement? =  lookupAchievement.1
                
                if let achievement = lookupAchievement {
                    GKAchievement.resetAchievementsWithCompletionHandler({ (error:Error!) -> Void in
                        if error != nil {
                            println("Couldn't Reset achievement (\(achievementID))")
                        } else {
                            println("Reset achievement (\(achievementID))")
                        }
                    })
                    
                } else {
                    print("No achievement with ID (\(achievementID)) was found, no progress for this one was recoreded yet. Create achievement now.")
                    gameCenterAchievements[achievementID] = GKAchievement(identifier: achievementID)
                    /* recursive recall this func now that the achievement exist */
                    self.resetAchievements(achievementIdentifier: achievementID)
                }
            }
        }
    }
    /**
        Show Game Center Player
    */
    func showGameCenter() {
        if canUseGameCenter == true {
            var gc = GKGameCenterViewController()
            gc.gameCenterDelegate = self
            self.vc.present(gc, animated: true, completion: nil)
        }
    }
}
