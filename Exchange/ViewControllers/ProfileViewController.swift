//
//  ProfileViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/6/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var profileBackView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var jobLabel: UILabel!
    
    @IBOutlet weak var linkedInButton: UIButton!
    
    @IBOutlet weak var contactInfoButton: UIButton!
    
    let user = PFUser.currentUser()!
    
    override func viewDidLoad(){
        
        UIChanges()
        setNeedsStatusBarAppearanceUpdate()
        
        displayUser()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func displayUser(){
        // i) profileImage
        if let imageFile = user.valueForKey("profilePicture") as! PFFile?{ // If user has a profile image...
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?,  error: NSError?) -> Void in
                if error != nil{
                    print(error?.localizedDescription)
                }else{
                    if let imageData = data{
                        self.profileImageView.image = UIImage(data: imageData)
                    }
                }
            })
        }else{ // TODO: Otherwise set a default
            
        }
        
        // ii) name
        let firstName = (user.valueForKey("firstName") as! String?) ?? ""
        let lastName = (user.valueForKey("lastName") as! String?) ?? ""
        
        nameLabel.text = "\(firstName) \(lastName)"
    }
    
    // UI Changes that cannot be done in storyboard
    func UIChanges(){
        profileImageView.layer.borderColor = UIElementProperties.textColor.CGColor
        
        // i) Buttons
        linkedInButton.backgroundColor = UIColor(red: 0.0/255.0, green: 123.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        contactInfoButton.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 14.0/255.0, alpha: 1.0)
    }
}
