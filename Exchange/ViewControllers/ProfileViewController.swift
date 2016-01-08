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
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var infoDoneButton: UIButton!
    // text fields dict
    var textFields: [Int: String]?
    
    var inEditMode: Bool = false
    
    var inViewMode: Bool = false
    
    // Everything related to edit view
    
    @IBOutlet weak var positionLeading: NSLayoutConstraint!
    
    @IBOutlet weak var companyLeading: NSLayoutConstraint!
    
    @IBAction func showLinkedIn(sender: AnyObject) {
        if let userExtension = user.valueForKey("linkedIn") as! String?{
            let URL = "https://www.linkedin.com/in/\(userExtension)"
            
            let encodedURL = NSURL(string: URL)
            if let encodedURL = encodedURL{
                UIApplication.sharedApplication().openURL(encodedURL)
            }else{
                print("This url does not exist")
            }
        }else{
            print("User does not have a linkedIn")
        }
    }
    
    @IBAction func showEdit(sender: AnyObject) {
        if !inEditMode{
            inEditMode = true
            
            profileImageView.userInteractionEnabled = true
            
            editButton.setTitle("Done", forState: UIControlState.Normal)
            
            infoDoneButton.hidden = true
            
            self.phoneField.enabled = true
            self.emailField.enabled = true
            self.phoneField.backgroundColor = UIColor.whiteColor()
            self.emailField.backgroundColor = UIColor.whiteColor()
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.jobLabel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * (self.view.frame.width/2.0 + self.jobLabel.frame.width), 0.0)
                
                self.positionLeading.constant =  -1.0 * (self.view.frame.width - ((self.view.frame.width - (2 * self.positionField.frame.width + self.companyLeading.constant))/2.0))
                
                self.linkedInButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.linkedInButton.frame.width, 0.0)
                
                self.contactInfoButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.contactInfoButton.frame.width, 0.0)
                
                self.infoView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * self.infoView.frame.width, 0.0)
                
                self.aboutTextView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, 1.0 * self.infoView.frame.height - 20)
                
                self.profileImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75)
                
                self.view.layoutIfNeeded()
            })
        }else{
            inEditMode = false
            
            profileImageView.userInteractionEnabled = false
            
            endEditing()
            
            editButton.setTitle("Edit", forState: UIControlState.Normal)
            
            displayUser()
            
            let animation = { () -> Void in
                self.jobLabel.transform = CGAffineTransformIdentity
                
                self.positionLeading.constant = 0.0
                
                self.linkedInButton.transform = CGAffineTransformIdentity
                
                self.contactInfoButton.transform = CGAffineTransformIdentity
                
                self.infoView.transform = CGAffineTransformIdentity
                
                self.aboutTextView.transform = CGAffineTransformIdentity
                
                self.profileImageView.transform = CGAffineTransformIdentity
                
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: { (succeeded: Bool) -> Void in
                self.infoDoneButton.hidden = false
                self.phoneField.enabled = false
                self.emailField.enabled = false
                self.phoneField.backgroundColor = UIElementProperties.textColor
                self.emailField.backgroundColor = UIElementProperties.textColor
            })
            
            user.saveInBackground()
        }
    }
    
    // Everything related to the info view
    @IBOutlet weak var infoView: UIView!
    
    
    
    
    // Animates the info view in
    @IBAction func showInfoView(sender: AnyObject) {
        if !inEditMode{
            inViewMode = true
            let animation = { () -> Void in
                self.linkedInButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.linkedInButton.frame.width, 0.0)
                self.contactInfoButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.contactInfoButton.frame.width, 0.0)
                self.infoView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * self.infoView.frame.width, 0.0)
                self.aboutTextView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, 1.0 * self.infoView.frame.height - 20)
                self.editButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.editButton.frame.width * 2.0, 0.0)
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: nil)
        }
    }
    
    @IBAction func hideInfoView(sender: AnyObject) {
        if !inEditMode{
            inViewMode = false
            let animation = { () -> Void in
                self.linkedInButton.transform = CGAffineTransformIdentity
                self.contactInfoButton.transform = CGAffineTransformIdentity
                self.infoView.transform = CGAffineTransformIdentity
                self.aboutTextView.transform = CGAffineTransformIdentity
                self.editButton.transform = CGAffineTransformIdentity
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: nil)
        }
    }
    
    var photoHelper: PhotoSelectorHelper?
    
    func changeProfileImage(){
        photoHelper = PhotoSelectorHelper(viewController: self, callback: { (image: UIImage?) -> Void in
            if let image = image{
                // Set the image
                //self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.profileImageView.image = image
                
                self.view.setNeedsLayout()
                
                // Now save the new image in parse backend
                let imageData = UIImageJPEGRepresentation(image, 0.8)
                let imageFile = PFFile(data: imageData!)
                self.user.setValue(imageFile, forKey: "profilePicture")
                self.user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error != nil{
                        print("\(error?.localizedDescription)")
                    }
                    if success{
                        print("Profile image saved succesfully.")
                    }else{
                        print("Unable to save image.")
                    }
                })
            }else{
                print("Unable to get image from image selection.")
            }
        })
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
        
        phoneField.delegate = self
        phoneField.tag = 2
        
        emailField.delegate = self
        emailField.tag = 3
        
        textFields = [positionField.tag: "position", companyField.tag: "company", phoneField.tag: "phoneNumber", emailField.tag: "email"]
        
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
        phoneField.text = (user.valueForKey("phoneNumber") as! String?) ?? ""
        emailField.text = (user.valueForKey("email") as! String?) ?? ""
        
    }
    
    // UI Changes that cannot be done in storyboard
    func UIChanges(){
        // o) Profile image view
        profileImageView.layer.borderColor = UIElementProperties.textColor.CGColor
        profileImageView.userInteractionEnabled = false
        
        // i) Buttons
        linkedInButton.backgroundColor = UIColor(red: 0.0/255.0, green: 123.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        contactInfoButton.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        
        // ii) About text view
        aboutTextView.backgroundColor = UIElementProperties.textColor
        aboutTextView.editable = false
        
        // iii) text fields
        phoneField.backgroundColor = UIElementProperties.textColor
        emailField.backgroundColor = UIElementProperties.textColor
        phoneField.enabled = false
        emailField.enabled = false
    }
    
    func addGestures(){
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: Selector("endEditing"))
        self.view.addGestureRecognizer(tapScreenGesture)
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: Selector("changeProfileImage"))
        self.profileImageView.addGestureRecognizer(tapProfileGesture)
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
