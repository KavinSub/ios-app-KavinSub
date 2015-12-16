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
    
    // Will logout the user
    @IBAction func logoutUser(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "userLoggedIn")
        PFUser.logOut()
        
        performSegueWithIdentifier("LogoutUser", sender: self)
    }
    
    @IBAction func deleteUser(sender: AnyObject) {
        // To delete user, we must delete user object and all associated connections
        let user = PFUser.currentUser()
        // Delete associated connections
        // (i) Find all connections
        let connectionQuery = PFQuery(className: "Connection")
        connectionQuery.whereKey("other_user", equalTo: user!)
        connectionQuery.whereKey("this_user", equalTo: user!)
        
        
        connectionQuery.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) -> Void in
            if error != nil{
                print("\(error?.localizedDescription)")
            }
            
            // (ii) For each connection object in the result, delete it
            if let result = result{
                for connection in result{
                    do{
                        try connection.delete()
                    }catch{
                        print("Unable to delete connection")
                        return
                    }
                }
            }
        }
        
        // Delete user
        user?.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if (error != nil){
                print("\(error?.localizedDescription)")
            }
            if !success{
                print("Unable to delete user")
                return
            }else{
                // Now ensure the user is treated as logged out
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "userLoggedIn")
                PFUser.logOut()
                
                self.performSegueWithIdentifier("LogoutUser", sender: self)
            }
        })
    }
}
