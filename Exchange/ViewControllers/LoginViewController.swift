//
//  LoginViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/18/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Google

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // Create Facebook button
        let facebookLoginButton = FBSDKLoginButton()
        facebookLoginButton.center = self.view.center
        self.view.addSubview(facebookLoginButton)
        
        // Set this controller to be the Google UI Delegate
        GIDSignIn.sharedInstance().uiDelegate = self
        let googleLoginButton = GIDSignInButton()
        googleLoginButton.center = CGPoint(x: 200, y: 200)
        self.view.addSubview(googleLoginButton)
        
    }
    
    
    
    
    
}
