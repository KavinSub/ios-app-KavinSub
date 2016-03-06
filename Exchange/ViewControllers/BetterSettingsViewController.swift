//
//  BetterSettingsViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/9/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class BetterSettingsViewController: UITableViewController {

    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var linkedInField: UITextField!
    
    @IBOutlet weak var firstNameFieldCount: UILabel!
    
    @IBOutlet weak var lastNameFieldCount: UILabel!
    
    @IBOutlet weak var switchControl: UISwitch!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func openPolicy(sender: AnyObject) {
        let url : NSURL = NSURL(string: "http://kavinsub.github.io/Exchange-App/")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func toggleExchange(sender: AnyObject) {
        let value = switchControl.on
        
        ExchangeViewController.allowExchange = value
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: "allowExchange")
    }
    
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
    

    func logoutAccount(){
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "userLoggedIn")
        PFUser.logOut()
        
        performSegueWithIdentifier("LogoutUser", sender: self)
    }
    
    @IBAction func deleteUser(sender: AnyObject) {
        
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
    
    let user = PFUser.currentUser()!
    
    let maxLength: Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIElementProperties.textColor
        
        firstNameField.text = (user.valueForKey("firstName") as! String?) ?? ""
        lastNameField.text = (user.valueForKey("lastName") as! String?) ?? ""
        linkedInField.text = (user.valueForKey("linkedIn") as! String?) ?? ""
        
        firstNameFieldCount.hidden = true
        lastNameFieldCount.hidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboards"))
        self.view.addGestureRecognizer(tapGesture)
        
        switchControl.setOn(NSUserDefaults.standardUserDefaults().valueForKey("allowExchange") as! Bool? ?? true, animated: true)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIElementProperties.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboards(){
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BetterSettingsViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(textField: UITextField) {
        var key: String?
        if textField.tag == 0{
            key = "firstName"
            firstNameFieldCount.hidden = true
        }else if textField.tag == 1{
            key = "lastName"
            lastNameFieldCount.hidden = true
        }else if textField.tag == 2{
            key = "linkedIn"
        }
        
        user.setValue(textField.text, forKey: key!)
        user.saveInBackground()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 0{
            firstNameFieldCount.hidden = false
            firstNameFieldCount.text = String(maxLength - Int((textField.text?.characters.count)!))
        }else if textField.tag == 1{
            lastNameFieldCount.hidden = false
            lastNameFieldCount.text = String(maxLength - Int((textField.text?.characters.count)!))
        }
    }
    
    
    // CREDIT TO: http://stackoverflow.com/a/8913595/5584144 for character replacement beyond character range
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldLength = textField.text?.characters.count
        let replacementLength = string.characters.count
        let rangeLength = range.length
        
        let newLength = oldLength! - rangeLength + replacementLength
    
        let val = newLength <= maxLength
        
        if val{
            if textField.tag == 0{
                firstNameFieldCount.text = String(maxLength - newLength)
            }else if textField.tag == 1{
                lastNameFieldCount.text = String(maxLength - newLength)
            }
        }
        return val
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

