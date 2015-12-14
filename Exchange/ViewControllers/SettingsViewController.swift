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
    }
    
    @IBAction func deleteUser(sender: AnyObject) {
        
    }
}
