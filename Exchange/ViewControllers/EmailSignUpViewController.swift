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
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    // Array of text fields
    var textFields: [(UITextField, String)] = []
    
    @IBAction func signUp(sender: AnyObject) {
        signUpUser()
    }
    
    override func viewDidLoad(){
        // Gesture will close any first responders
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        
        // Initialize textfields array
        textFields = [
        (firstNameField, "firstName"),
        (lastNameField, "lastName"),
        (emailField, "email"),
        (passwordField, "password")]
    }
    
    // Keyboard will dismissed upon call
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    func signUpUser(){
        // First verify all fields have been filled out
        if !verifyFieldsFilledOut(){
            presentAlertViewController("Please fill out all fields.")
            return
        }
        
        //let user = PFUser.currentUser()
        let user = PFObject(className: "User")
        
        for field in textFields{
            let text = field.0.text
            let key = field.1
            if key == "password"{
                if !isAlphanumeric(text!){
                    presentAlertViewController("Password should only contain letters and numbers.")
                    return
                }
            }
            
            user.setValue(text, forKey: key)
        }
        
        print("\(user)")
    }
    
    func verifyFieldsFilledOut() -> Bool{
        var count = 0
        for field in textFields{
            if let text = field.0.text{
                if text != ""{
                    count = count + 1
                }
            }
        }
        return count == textFields.count
    }
    
    func presentAlertViewController(message: String){
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertViewController.addAction(alertAction)
        
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    // Returns true if a string's characters are alphanumeric
    func isAlphanumeric(string: String) -> Bool{
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        for char in string.unicodeScalars{
            if !(letters.longCharacterIsMember(char.value) || digits.longCharacterIsMember(char.value)){
                return false
            }
        }
        return true
    }
    
}