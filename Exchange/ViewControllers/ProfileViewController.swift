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
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var positionField: UITextField!
    
    @IBOutlet weak var companyField: UITextField!
    
    // text fields dict
    var textFields: [Int: String]?
    
    var inEditMode: Bool = false
    
    // Everything related to edit view
    
    @IBOutlet weak var positionLeading: NSLayoutConstraint!
    
    @IBOutlet weak var companyLeading: NSLayoutConstraint!
    
    @IBAction func showEdit(sender: AnyObject) {
        if !inEditMode{
            inEditMode = true
            
            editButton.setTitle("Done", forState: UIControlState.Normal)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.jobLabel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * (self.view.frame.width/2.0 + self.jobLabel.frame.width), 0.0)
                
                self.positionLeading.constant =  -1.0 * (self.view.frame.width - ((self.view.frame.width - (2 * self.positionField.frame.width + self.companyLeading.constant))/2.0))
                
                self.view.layoutIfNeeded()
            })
        }else{
            inEditMode = false
            
            endEditing()
            
            editButton.setTitle("Edit", forState: UIControlState.Normal)
            
            displayUser()
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.jobLabel.transform = CGAffineTransformIdentity
                
                self.positionLeading.constant = 0.0
                
                self.view.layoutIfNeeded()
            })
            
            user.saveInBackground()
        }
    }
    
    // Everything related to the info view
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    // Animates the info view in
    @IBAction func showInfoView(sender: AnyObject) {
       let animation = { () -> Void in
            self.linkedInButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.linkedInButton.frame.width, 0.0)
            self.contactInfoButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.contactInfoButton.frame.width, 0.0)
            self.infoView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * self.infoView.frame.width, 0.0)
            self.aboutTextView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, 1.0 * self.infoView.frame.height - 20)
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: nil)
    }
    
    @IBAction func hideInfoView(sender: AnyObject) {
        let animation = { () -> Void in
            self.linkedInButton.transform = CGAffineTransformIdentity
            self.contactInfoButton.transform = CGAffineTransformIdentity
            self.infoView.transform = CGAffineTransformIdentity
            self.aboutTextView.transform = CGAffineTransformIdentity
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: nil)
    }
    
    
    let user = PFUser.currentUser()!
    
    override func viewDidLoad(){
        
        UIChanges()
        addGestures()
        setNeedsStatusBarAppearanceUpdate()
        
        positionField.delegate = self
        positionField.tag = 0
        
        companyField.delegate = self
        companyField.tag = 1
        
        textFields = [positionField.tag: "position", companyField.tag: "company"]
        
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
        
        // iii) company and position
        let position = (user.valueForKey("position") as! String?) ?? ""
        let company = (user.valueForKey("company") as! String?) ?? ""
        if position == "" && company == ""{
            jobLabel.text = "Works at"
        }else if position == ""{
            jobLabel.text = "Works at \(company)"
        }else if company == ""{
            jobLabel.text = "Works as \(position)"
        }else{
            jobLabel.text = "\(position) at \(company)"
        }
        
        positionField.text = position
        companyField.text = company
        
        // iv) contact info
        phoneNumberLabel.text = (user.valueForKey("phoneNumber") as! String?) ?? ""
        emailLabel.text = (user.valueForKey("email") as! String?) ?? ""
        
    }
    
    // UI Changes that cannot be done in storyboard
    func UIChanges(){
        profileImageView.layer.borderColor = UIElementProperties.textColor.CGColor
        
        // i) Buttons
        linkedInButton.backgroundColor = UIColor(red: 0.0/255.0, green: 123.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        contactInfoButton.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        
        // ii) About text view
        aboutTextView.backgroundColor = UIElementProperties.textColor
        aboutTextView.editable = false
    }
    
    func addGestures(){
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: Selector("endEditing"))
        self.view.addGestureRecognizer(tapScreenGesture)
    }
    
    func endEditing(){
        self.view.endEditing(true)
    }
    
}

extension ProfileViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(textField: UITextField) {
        let key = textFields![textField.tag]!
        let value = textField.text
        
        user.setValue(value, forKey: key)
    }
}
