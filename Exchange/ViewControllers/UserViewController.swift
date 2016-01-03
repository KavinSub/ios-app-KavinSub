//
//  UserViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/2/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class UserViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var contactInfoView: UIView!
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    // Goes back to the previous view controller
    @IBAction func goBack(sender: AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // If true, edit button is present
    var allowsEditMode: Bool?
    
    // User that is to be displayed on this view controller
    var user: PFUser?
    
    override func viewDidLoad(){
        displayUser(user!)
        changeButtons()
    }
    
    func displayUser(user: PFUser){
        // Display users name
        let firstName = user.valueForKey("firstName") as! String?
        let lastName = user.valueForKey("lastName") as! String?
        
        if let firstName = firstName, lastName = lastName{
            nameLabel.text = "\(firstName) \(lastName)"
        }
        
        // Display users profile image
        // i) Image display settings - Credit to http://www.appcoda.com/ios-programming-circular-image-calayer/
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
        self.profileImageView.clipsToBounds = true
        
        self.profileImageView.layer.borderWidth = 3.0
        self.profileImageView.layer.borderColor = UIElementProperties.textColor.CGColor
        
        // TODO: If user does not have image, show default image
        // ii) Download image file
        let imageFile = user.valueForKey("profilePicture") as! PFFile?
        if let imageFile = imageFile{
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                if error != nil{
                    print("\(error?.localizedDescription)")
                }
                
                if let data = data{
                    let image = UIImage(data: data)!
                    self.profileImageView.image = image
                }
            })
        }
        
        // Change contact info view
        contactInfoView.layer.cornerRadius = contactInfoView.frame.size.width/2
        contactInfoView.clipsToBounds = true
        
        // Add content to text view
        if let text = user.valueForKey("about") as! String?{
            aboutTextView.text = text
        }
        aboutTextView.editable = false
    }
    
    // Changes settings of edit and back button
    func changeButtons(){
        if allowsEditMode!{
            // Add constraints to back button
            let backTopConstraint = NSLayoutConstraint(item: backButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .TopMargin, multiplier: 1.0, constant: 24.0)
            let backTrailingConstraint = NSLayoutConstraint(item: backButton, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0)
            
            self.view.addConstraint(backTopConstraint)
            self.view.addConstraint(backTrailingConstraint)
            
            // Add constraints to the back button
            let editTopConstraint = NSLayoutConstraint(item: editButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .TopMargin, multiplier: 1.0, constant: 24.0)
            let editLeadingConstraint = NSLayoutConstraint(item: editButton, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .LeadingMargin, multiplier: 1.0, constant: 0.0)
            
            self.view.addConstraint(editTopConstraint)
            self.view.addConstraint(editLeadingConstraint)
        }
    }
}



