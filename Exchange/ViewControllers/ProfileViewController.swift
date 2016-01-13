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
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var infoDoneButton: UIButton!
    
    // text fields dict
    var textFields: [Int: String]?
    
    var inEditMode: Bool = false
    
    var inViewMode: Bool = false
    
    var enteredNumber = ""
    
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
            
            editButton.userInteractionEnabled = false
            
            profileImageView.userInteractionEnabled = true
            
            editButton.setTitle("Done", forState: UIControlState.Normal)
            
            infoDoneButton.hidden = true
            
            self.aboutTextView.editable = true
            
            self.phoneField.enabled = true
            self.emailField.enabled = true
            
            self.emailLabel.hidden = true
            self.phoneLabel.hidden = true
            
            // Animate about box first to avoid collisions
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.aboutTextView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, 1.0 * self.infoView.frame.height - (self.infoDoneButton.frame.height * 3.0 + 10.0))
                
                self.aboutTextView.backgroundColor = UIColor.whiteColor()
                
            })
            
            let borderAnimation = CABasicAnimation(keyPath: "borderColor")
            borderAnimation.fromValue = UIColor.clearColor().CGColor
            borderAnimation.toValue = UIColor.blackColor().CGColor
            borderAnimation.repeatCount = 1.0
            borderAnimation.duration = 0.5
            
            self.aboutTextView.layer.addAnimation(borderAnimation, forKey: "borderColor")
            
            self.aboutTextView.layer.borderColor = UIColor.blackColor().CGColor
            

            // Now animate everything else
            
            let animation = { () -> Void in
                self.jobLabel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * (self.view.frame.width/2.0 + self.jobLabel.frame.width), 0.0)
                
                self.positionLeading.constant =  -1.0 * (self.view.frame.width - ((self.view.frame.width - (2 * self.positionField.frame.width + self.companyLeading.constant))/2.0))
                
                self.linkedInButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.linkedInButton.frame.width, 0.0)
                
                self.contactInfoButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.contactInfoButton.frame.width, 0.0)
                
                self.infoView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * self.infoView.frame.width, 0.0)
                
                self.profileImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75)
                
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: { (success: Bool) -> Void in
                self.editButton.userInteractionEnabled = true
            })
        }else{
            inEditMode = false
            
            profileImageView.userInteractionEnabled = false
            
            endEditing()
            
            editButton.userInteractionEnabled = false
            
            editButton.setTitle("Edit", forState: UIControlState.Normal)
            
            self.aboutTextView.editable = false
            
            displayUser()
            
            let animation = { () -> Void in
                self.jobLabel.transform = CGAffineTransformIdentity
                
                self.positionLeading.constant = 0.0
                
                self.linkedInButton.transform = CGAffineTransformIdentity
                
                self.contactInfoButton.transform = CGAffineTransformIdentity
                
                self.infoView.transform = CGAffineTransformIdentity
                
                self.profileImageView.transform = CGAffineTransformIdentity
                
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: { (succeeded: Bool) -> Void in
                self.infoDoneButton.hidden = false
                self.phoneField.enabled = false
                self.emailField.enabled = false
                self.phoneLabel.hidden = false
                self.emailLabel.hidden = false
                self.phoneField.backgroundColor = UIElementProperties.textColor
                self.emailField.backgroundColor = UIElementProperties.textColor
                self.editButton.userInteractionEnabled = true
            })
            
            // Animate about view last
            
            let aboutAnimation = { () -> Void in
                self.aboutTextView.transform = CGAffineTransformIdentity
                self.aboutTextView.backgroundColor = UIElementProperties.textColor
            }
            
            UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: aboutAnimation, completion: nil)
            
            let borderAnimation = CABasicAnimation(keyPath: "borderColor")
            borderAnimation.fromValue = UIColor.blackColor().CGColor
            borderAnimation.toValue = UIColor.clearColor().CGColor
            borderAnimation.repeatCount = 1.0
            borderAnimation.duration = 0.5
            
            self.aboutTextView.layer.addAnimation(borderAnimation, forKey: "borderColor")
            
            self.aboutTextView.layer.borderColor = UIColor.clearColor().CGColor
            
            user.saveInBackground()
        }
    }
    
    // Everything related to the info view
    @IBOutlet weak var infoView: UIView!
    
    // Animates the info view in
    @IBAction func showInfoView(sender: AnyObject) {
        if !inEditMode{
            inViewMode = true
            
            phoneField.hidden = true
            emailField.hidden = true
            
            phoneLabel.text = (user.valueForKey("phoneNumber") as! String?) ?? ""
            emailLabel.text = (user.valueForKey("email") as! String?) ?? ""
            
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
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: animation, completion: { (success: Bool) -> Void in
                self.phoneField.hidden = false
                self.emailField.hidden = false
                
            })
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
    
    
    var user = PFUser.currentUser()!
    
    override func viewDidLoad(){
        
        print("\(user)")
        
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
        
        aboutTextView.delegate = self
        aboutTextView.layer.borderColor = UIColor.clearColor().CGColor
        aboutTextView.layer.borderWidth = 1.0
        
        
        displayUser()
        
        // Email and Phone Fields
        let leftView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        leftView.backgroundColor = UIColor.clearColor()
        
        phoneField.leftView = leftView
        phoneField.leftViewMode = UITextFieldViewMode.Always
        phoneField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        let emailLeftView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        emailLeftView.backgroundColor = UIColor.clearColor()
        
        emailField.leftView = emailLeftView
        emailField.leftViewMode = UITextFieldViewMode.Always
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        // v) about text view
        aboutTextView.text = (user.valueForKey("about") as! String?) ?? ""
        
        // vi) Phone Number
        enteredNumber = user.valueForKey("phoneNumber") as! String? ?? ""
        if enteredNumber != ""{
            enteredNumber = stripNonNumbers(enteredNumber)
        }
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
        
        let swipeContactGesture = UISwipeGestureRecognizer(target: self, action: Selector("showInfoView:"))
        swipeContactGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.contactInfoButton.addGestureRecognizer(swipeContactGesture)
        
        let swipeInfoGesture = UISwipeGestureRecognizer(target: self, action: Selector("hideInfoView:"))
        self.infoView.addGestureRecognizer(swipeInfoGesture)
    }
    
    func endEditing(){
        self.view.endEditing(true)
    }
    
    // Keeps only the numbers of the string
    func stripNonNumbers(string: String) -> String{
        let numberSet: Set<Character> = Set("0123456789".characters)
        let characters = Array(string.characters)
        
        var returnable = ""
        
        for character in characters{
            if numberSet.contains(character){
                returnable += String(character)
            }
        }
        return returnable
    }
    
    // Formats a number into (xxx) xxx-xxxx
    func formatNumber(number: String) -> String{
        let count = number.characters.count
        
        let index = number.startIndex
        
        if count == 0{
            return ""
        }else if count >= 1 && count < 3{
            return String(format: "(%@", arguments: [number.substringToIndex(index.advancedBy(count))])
        }else if count == 3{
            return String(format: "(%@)", arguments: [number.substringToIndex(index.advancedBy(3))])
        }else if count > 3 && count <= 6{
            return String(format: "(%@) %@", arguments: [number.substringToIndex(index.advancedBy(3)), number.substringWithRange(Range(start: index.advancedBy(3), end: index.advancedBy(count)))])
        }else{
            return String(format: "(%@) %@-%@", arguments: [number.substringToIndex(index.advancedBy(3)), number.substringWithRange(Range(start: index.advancedBy(3), end: index.advancedBy(6))), number.substringWithRange(Range(start: index.advancedBy(6), end: index.advancedBy(count)))])
        }
    }
}

extension ProfileViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == phoneField.tag{
            textField.text = enteredNumber
        }
        
        if textField.tag == phoneField.tag || textField.tag == emailField.tag{
            textField.layer.borderColor = UIElementProperties.backgroundColor.CGColor
            textField.layer.borderWidth = 1.0
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let key = textFields![textField.tag]!
        let value = textField.text
        
        user.setValue(value, forKey: key)
        
        if textField.tag == self.phoneField.tag{
            if textField.text?.characters.count >= 0 && textField.text?.characters.count <= 10{
                enteredNumber = stripNonNumbers(textField.text! ?? "")
            }else{
                enteredNumber = stripNonNumbers(textField.text!.substringToIndex(textField.text!.startIndex.advancedBy(10)))
            }
            let formatted = formatNumber(enteredNumber)
            textField.text = formatted
            user.setValue(formatted, forKey: "phoneNumber")
        }
        
        if textField.tag == phoneField.tag || textField.tag == emailField.tag{
            textField.layer.borderWidth = 0.0
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileViewController: UITabBarDelegate{
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print("Selected item")
    }
}

extension ProfileViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.layer.borderColor = UIElementProperties.backgroundColor.CGColor
        
        let animation = { () -> Void in
            self.view.center.y -= (216)
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: animation, completion: nil)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.layer.borderColor = UIColor.blackColor().CGColor
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.center.y += (216)
        }
        
        let key = "about"
        let value = textView.text
        
        user.setValue(value, forKey: key)
        
    }
}
