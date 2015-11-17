//
//  LoginViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/16/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
    }
    
    func loginWithFacebook(){
        let permissionsArray: [String] = ["user_about_me", "user_relationships", "user_birthday", "user_location"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray) { (user: PFUser?, error: NSError?) -> Void in
            if let user = user{
                if(user.isNew){
                    print("User has signed up, and logged in through facebook.")
                }else{
                    print("User logged in the facebook.")
                }
            }else{
                print("User has cancelled facebook login")
            }
        }
    }
}
