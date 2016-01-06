//
//  SettingsViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/14/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // Tag -> Key
    var textFields: [Int: String]?
    
    @IBAction func logoutTouchUpOutside(sender: AnyObject){
        logoutButton.backgroundColor = UIColor.whiteColor()
    }
    
    
    @IBAction func deleteTouchUpOutside(sender: AnyObject) {
        deleteButton.backgroundColor = UIColor.whiteColor()
    }
    
    
    @IBAction func logoutTouchDown(sender: AnyObject) {
        logoutButton.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
    }
    
    @IBAction func deleteTouchDown(sender: AnyObject) {
        deleteButton.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
    }
    
    
    // Will logout the user (touch up inside)
    @IBAction func logoutUser(sender: AnyObject) {
        
        logoutButton.backgroundColor = UIColor.whiteColor()
        
        let message = "Are you sure you want to logout?"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive) { (action: UIAlertAction) -> Void in
            self.logoutAccount()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Will delete the users account (touch up inside)
    @IBAction func deleteUser(sender: AnyObject) {
        
        deleteButton.backgroundColor = UIColor.whiteColor()
        
        let message = "If you delete your account, you will permanently lose your profile, and all connections.\n\nIn addition, all your connections will no longer be able to view your profile.\n\nAre you sure want to delete your account?"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete Account", style: .Destructive) { (action: UIAlertAction) -> Void in
            self.deleteAccount()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func logoutAccount(){
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "userLoggedIn")
        PFUser.logOut()
        
        performSegueWithIdentifier("LogoutUser", sender: self)
    }
    
    func deleteAccount(){
        // To delete user, we must delete user object and all associated connections
        let user = PFUser.currentUser()!
        // Delete associated connections
        // (i) Find all connections
        let yourConnectionsQuery = PFQuery(className: "Connection")
        yourConnectionsQuery.whereKey("this_user", equalTo: user)
        
        let otherConnectionsQuery = PFQuery(className: "Connection")
        otherConnectionsQuery.whereKey("other_user", equalTo: user)
        
        let connectionQuery = PFQuery.orQueryWithSubqueries([yourConnectionsQuery, otherConnectionsQuery])
        
        connectionQuery.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) -> Void in
            if error != nil{
                print("\(error?.localizedDescription)")
            }
            
            if let result = result{
                print("\(result.count)")
            }
            
            // (ii) For each connection object in the result, delete it
            PFObject.deleteAllInBackground(result, block: { (succeeded: Bool, error: NSError?) -> Void in
                // (iii) Delete user
                user.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if (error != nil){
                        print("\(error?.localizedDescription)")
                    }
                    
                    if !success{
                        // Backend of user has likely already been deleted, but changes not reflected.
                        print("Unable to delete user")
                        
                        // Perform logout segue for user anyways
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "userLoggedIn")
                        self.performSegueWithIdentifier("LogoutUser", sender: self)
                        
                    }else{
                        // Now ensure the user is treated as logged out
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "userLoggedIn")
                        PFUser.logOut()
                        
                        self.performSegueWithIdentifier("LogoutUser", sender: self)
                    }
                })
            })
        }
    }
    
    override func viewDidLoad(){
        prepareTextFields()
        setupGestures()
    }
    
    func prepareTextFields(){
        
        let user = PFUser.currentUser()!
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        if let firstName = user.valueForKey("firstName") as! String?{
            firstNameTextField.text = firstName
        }
        
        if let lastName = user.valueForKey("lastName") as! String?{
            lastNameTextField.text = lastName
        }
        
        firstNameTextField.tag = 0
        lastNameTextField.tag = 1
        
        textFields = [firstNameTextField.tag: "firstName", lastNameTextField.tag: "lastName"]
    }
    
    func setupGestures(){
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: Selector("closeKeyboards"))
        self.view.addGestureRecognizer(tapScreenGesture)
    }
    
    func closeKeyboards(){
        self.view.endEditing(true)
    }
}

extension SettingsViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text
        let key = textFields![textField.tag]!
        
        if let text = text{
            let user = PFUser.currentUser()
            user?.setValue(text, forKey: key)
            
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if error != nil{
                    print(error?.localizedDescription)
                }
                
                if success{
                    print("\(text) succesfully saved for \(key) key.")
                }else{
                    print("Unable to save \(text) for \(key) key.")
                }
            })
        }
    }
}
