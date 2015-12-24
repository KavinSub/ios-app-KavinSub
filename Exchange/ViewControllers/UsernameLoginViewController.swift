//
//  UsernameLoginViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/23/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class UsernameLoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginUser(sender: AnyObject) {
        loginUser()
    }
    
    // Checks the user's username and password, logs them in
    func loginUser(){
        if let username = usernameField.text, let password = passwordField.text{
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser?, error: NSError?) -> Void in
                if error != nil{
                    print("\(error?.localizedDescription)")
                }
                
                if let user = user{
                    NSUserDefaults.standardUserDefaults().setValue(true, forKey: "userLoggedIn")
                    print("User has succesfully logged in.")
                }else{
                    print("Invalid user credentials.")
                }
            })
        }
    }
    
}
