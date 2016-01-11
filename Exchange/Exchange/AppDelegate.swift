//
//  AppDelegate.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/18/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import Google

//import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var login: loginType?
    
    var networkHelper = NetworkHelper()
    
    var reachability: Reachability? = nil
    
    enum loginType{
        case Facebook
        case Google
        case LinkedIn
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Parse setup
        Parse.setApplicationId("A1CXwoBtfmKLnmYmcN3WR8QTEQNen5jkkXka9D3J", clientKey: "gVwXTox341ckfYk261hjQba9FxlEvJutJZwUs6rh")
        
        // Facebook setup
        /*FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)*/
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // Google setup
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
        // Add observer for network connectivity changes
        
        
        /*do{
            reachability = try Reachability.reachabilityForInternetConnection()
            
            NSNotificationCenter.defaultCenter().addObserver(self.networkHelper, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability!)
            
            try reachability!.startNotifier()
        }catch{
            print("Unable to create Reachability.")
        }*/
        
        // Choose correct view controller
        let hasLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("userLoggedIn")
        print("\(hasLoggedIn)")
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var rootViewController: UIViewController
        
        if !hasLoggedIn{
            rootViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        }else{
            /*rootViewController = storyboard.instantiateViewControllerWithIdentifier("ExchangeViewController") as! ExchangeViewController*/
            
            rootViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        }
        
        self.window?.rootViewController = rootViewController
        
        self.window?.makeKeyAndVisible()
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Facebook setup
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // ***********GOOGLE********** 
    // Functions for GIDSignInDelegate
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if(error == nil){
            // Perform sign in operations
        }else{
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        // Perform operations when user disconnects from app
    }


}

