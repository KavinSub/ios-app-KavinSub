//
//  EmailSignUpViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/15/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class EmailSignUpViewController: UIViewController {
    
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let minFieldLength = 5
    let maxFieldLength = 20
    
    var reachability: Reachability?
    
    @IBAction func signUp(sender: AnyObject) {
        
        if reachability!.currentReachabilityStatus == Reachability.NetworkStatus.NotReachable{
            
            let alertController = UIAlertController(title: nil, message: "No internet connection, unable to sign up.", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        signUpUser()
    }
    
    @IBAction func unwindToUserSignUpSegue(storyboard: UIStoryboardSegue){
    }
    
    override func viewDidLoad(){
        
        errorLabel.alpha = 0.0
        
        // Gesture will close any first responders
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        
        let leftView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        leftView.backgroundColor = UIColor.clearColor()
        
        usernameField.leftView = leftView
        usernameField.leftViewMode = UITextFieldViewMode.Always
        usernameField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        let passView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        passView.backgroundColor = UIColor.clearColor()
        
        passwordField.leftView = passView
        passwordField.leftViewMode = UITextFieldViewMode.Always
        passwordField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        let cPassView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        cPassView.backgroundColor = UIColor.clearColor()
        
        confirmPasswordField.leftView = cPassView
        confirmPasswordField.leftViewMode = UITextFieldViewMode.Always
        confirmPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        usernameField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        reachability = try! Reachability.reachabilityForInternetConnection()
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
    }
    
    // Keyboard will dismissed upon call
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    func signUpUser(){
        if !verifyFieldsFilledOut(){
            presentAlertViewController("Please fill out all fields.")
            return
        }
        
        if !verifyFieldsConditions(){
            return
        }
        
        let user = PFUser()
        let username = usernameField.text!
        let password = passwordField.text!
        user.setValue(username, forKey: "username")
        user.setValue(password, forKey: "password")
        
        user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if error != nil{
                print("\(error!.localizedDescription)")
                self.errorLabel.text = "Username \(username) already taken."
                if self.errorLabel.alpha < 1.0{
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.errorLabel.alpha = 1.0
                    })
                }else{
                    let animations = {() -> Void in
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: { () -> Void in
                            self.errorLabel.alpha = 0.0
                        })
                        
                        UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.5, animations: { () -> Void in
                            self.errorLabel.alpha = 1.0
                        })
                    }
                    
                   // Animate keyframes
                    UIView.animateKeyframesWithDuration(0.8, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: animations, completion: nil)
                }
            }
            
            if success{
                print("User has succesfully signed up.")
                // Now login the user
                do{
                    try PFUser.logInWithUsername(username, password: password)
                    NSUserDefaults.standardUserDefaults().setValue(true, forKey: "userLoggedIn")
                    print("User has succesfully logged in.")
                    self.performSegueWithIdentifier("Login", sender: self)
                }catch{
                    print("Unable to login user.")
                }
            }
        }
    }
    
    // Makes sure the fields have been filled out
    func verifyFieldsFilledOut() -> Bool{
        // If all fields have been filled out
        if usernameField.text != "" && passwordField.text !=  "" && confirmPasswordField.text != ""{
            return true
        }
        
        return false
    }
    
    // Checks that the fields fulfill certain conditions
    func verifyFieldsConditions() -> Bool{
        // Check that the fields use alphanumeric characters or symbols
        let username = usernameField.text
        let password = passwordField.text
        let confirmedPassword = confirmPasswordField.text
        
        let fieldTextError = "All fields must use letters, numbers or symbols"
        let mismatchedPasswordsError = "Both passwords must be equal."
        let lengthError = "All fields must be between \(minFieldLength) to \(maxFieldLength) characters"
        
        if !isValidRange(username!){
            presentAlertViewController("\(lengthError). Please fix username.")
            return false
        }
        
        if !isValidRange(password!){
            presentAlertViewController("\(lengthError). Please fix password.")
            return false
        }
        
        if !isValidRange(confirmedPassword!){
            presentAlertViewController("\(lengthError). Please fix confirmed password.")
            return false
        }
        
        if !isValidFieldString(username!){
            presentAlertViewController("\(fieldTextError). Please fix username.")
            return false
        }
        
        if !isValidFieldString(password!){
            presentAlertViewController("\(fieldTextError). Please fix password.")
            return false
        }
        
        if !isValidFieldString(confirmedPassword!){
            presentAlertViewController("\(fieldTextError). Please fix confirmed password.")
            return false
        }
        
        if password != confirmedPassword{
            presentAlertViewController(mismatchedPasswordsError)
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
    
    // Returns true if a string's characters are alphanumeric
    func isValidFieldString(string: String) -> Bool{
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        let symbols = NSCharacterSet(charactersInString: "!@#$%^&*()")
        
        for char in string.unicodeScalars{
            if !(letters.longCharacterIsMember(char.value) || digits.longCharacterIsMember(char.value) || symbols.longCharacterIsMember(char.value)){
                return false
            }
        }
        return true
    }
    
    func isValidRange(string: String) -> Bool{
        if string.characters.count >= minFieldLength && string.characters.count <= maxFieldLength{
            return true
        }
        
        return false
    }
}

extension EmailSignUpViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.layer.borderColor = UIElementProperties.backgroundColor.CGColor
        textField.layer.borderWidth = 1.0
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}