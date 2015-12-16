//
//  EmailSignUpViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/15/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit

class EmailSignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signUp(sender: AnyObject) {
        signUpUser()
    }
    
    override func viewDidLoad(){
        // Gesture will close any first responders
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // Keyboard will dismissed upon call
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    func signUpUser(){
        // First verify all fields have been filled out
        
        
    }
}