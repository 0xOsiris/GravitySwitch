//
//  GameViewController.swift
//  RetroRoute
//
//  Created by Leyton Taylor on 4/5/20.
//  Copyright © 2020 Leyton Taylor. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds
import GameKit
import StoreKit

protocol GADInterstitialDelegate{
    func showInterstitial()
}

class GameViewController: UIViewController, GameSceneDelegate, GKGameCenterControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate{
    
    var adMobBannerView = GADBannerView()
    var interstitial: GADInterstitial!
    
    
    
    var product: SKProduct?
    var productID = "com.leytontaylor.removeads"
    
    var scene : MainMenu?
    var gameScene : GameScene?
    let ADMOB_BANNER_UNIT_ID = "ca-app-pub-1379561659960903/5483672765"
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        
        
        // Create a fullscreen Scene object
        scene = MainMenu(fileNamed: "MainMenu")
        scene?.scaleMode = .aspectFit
        scene!.gameCenterDelegate = self
        scene!.viewController = self
        scene?.size = CGSize(width: skView.bounds.size.width, height: skView.bounds.size.height - 60)
        
        // Configure the view.
        
        
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        skView.presentScene(scene)
        
        SKPaymentQueue.default().add(self)
        getPurchaseInfo()
        self.initGameCenter()
        
        
    }
    
    func purchase(){
        if let myP = product {
           let payment = SKPayment(product: myP)
           SKPaymentQueue.default().add(payment)
        }
        else {
            print("Product is not found.")
        }
    }
    
    func getPurchaseInfo(){
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as! Set<String>)
            
            request.delegate = self
            request.start()
        }else{
            print("Warning")
            //productDescription.text = "Must enable in purchases"
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                
                case SKPaymentTransactionState.purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    //productTitle.text = "Thank You"
                    //productDescription.text = "The product has been purchased"
                    print("Purchased")
                    let save = UserDefaults.standard
                    save.set(true, forKey: "purchase")
                    save.synchronize()
                    
                
                case SKPaymentTransactionState.failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    print("Failed")
                    //productDescription.text = "The product has been purchased"

                default:
                    break
                
            }
        }
    }
    
    func setPurchaseEnabled() -> Bool{
        let save = UserDefaults.standard
        
        if save.bool(forKey: "purchase") == true{
            return(false)
        }else{
            return(true)
        }
    }
    
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products
        
        if(products.count == 0){
            print("Warning")
            //productDescription.text = "Product not found!"
        }else{
            print("Successful")
            product = products[0]
            
            //productTitle.text = product!.localizedTitle
            //productDescription.text = product!.localizedDescription
        }
        
        let invalids = response.invalidProductIdentifiers
        
        for product in invalids {
            print("Product not found: \(product)")
        }
    }
    //Show the interstitial ad
    func showInterstitial(){
        let save = UserDefaults.standard
        
        if save.value(forKey: "purchase") == nil{
             if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
                interstitial = createAd()
            
                print("Interstitial Shown")
             } else {
                print("Ad wasn't ready")
             }
        }
    }
    
    func createAd() -> GADInterstitial{
        let inter = GADInterstitial(adUnitID: "ca-app-pub-1379561659960903/2354591326")
        inter.load(GADRequest())
        return inter
    }
    
    func hideBanner(_ banner: UIView) {
            UIView.beginAnimations("hideBanner", context: nil)
            banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
            UIView.commitAnimations()
            banner.isHidden = true
    }
         
    // Show the banner
    func showBanner(_ banner: UIView) {
            UIView.beginAnimations("showBanner", context: nil)
            banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
            UIView.commitAnimations()
            banner.isHidden = false
    }
         
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
            showBanner(adMobBannerView)
    }
         
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
            hideBanner(adMobBannerView)
    }
    
    func initAdMobBanner() {
         
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
            
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
            
        } else  {
            // iPad
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 60))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 468, height: 60)
        }
         
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
             
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let save = UserDefaults.standard
        
        //if save.value(forKey: "purchase") == nil {
            
            //Initialize banner ad
            initAdMobBanner()
            //Initialize interstitial
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-1379561659960903/2354591326")
            let req = GADRequest()
            
            interstitial.load(req)
            
        //}
        
        
        authenticateUser()
        
        
    }
    
    private func authenticateUser(){
        let player = GKLocalPlayer.local
        player.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            if let vc = vc {
                
                self.present(vc, animated: true,
                             completion: nil)
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector:Selector(("gameCenterStateChanged")), name: NSNotification.Name(rawValue: "GKPlayerAuthenticationDidChangeNotificationName"), object: nil)
            }
        }
    }
    
    
    
    
    func showLeaderboard() {
        
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = "com.leytontaylor.gravityswitch.leaderboard"
        
        // Show leaderboard
        self.present(gcViewController, animated: true, completion: nil)
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
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        
    }
    // Initialize Game Center
    func initGameCenter() {
        
        // Check if user is already authenticated in game center
        if GKLocalPlayer.local.isAuthenticated == false {

            // Show the Login Prompt for Game Center
            GKLocalPlayer.local.authenticateHandler = {(viewController, error) -> Void in
                if viewController != nil {
                    
                    self.present(viewController ?? viewController!, animated: true, completion: nil)

                    // Add an observer which calls 'gameCenterStateChanged' to handle a changed game center state
                    let notificationCenter = NotificationCenter.default
                    notificationCenter.addObserver(self, selector:Selector(("gameCenterStateChanged")), name: NSNotification.Name(rawValue: "GKPlayerAuthenticationDidChangeNotificationName"), object: nil)
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
