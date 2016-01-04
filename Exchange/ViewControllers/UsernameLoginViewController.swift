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
    
    
    override func viewDidLoad(){
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // Dismiss open keyboards
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    // Checks the user's username and password, logs them in
    func loginUser(){
        
        if !checkTextFields(){
            return
        }
        
        if let username = usernameField.text, let password = passwordField.text{
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser?, error: NSError?) -> Void in
                if error != nil{
                    print("\(error?.localizedDescription)")
                }
                
                if let user = user{
                    NSUserDefaults.standardUserDefaults().setValue(true, forKey: "userLoggedIn")
                    print("User has succesfully logged in.")
                    self.performSegueWithIdentifier("Login", sender: self)
                }else{
                    print("Invalid user credentials.")
                    self.presentAlertViewController("Please enter correct username and password.")
                }
            })
        }
    }
    
    // Checks that a user has filled out text fields
    func checkTextFields() -> Bool{
        if usernameField.text == "" || passwordField.text == ""{
            presentAlertViewController("Please fill out all fields.")
            
            return false
        }
        
        return true
    }
    
    func presentAlertViewController(message: String){
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertViewController.addAction(alertAction)
        
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
}
