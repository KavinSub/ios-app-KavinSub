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
    
    @IBOutlet weak var linkedInView: UIView!
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var otherLinksView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    // All views related to the editor view component
    var editorView: UIView?
    
    var phoneNumberTextField: UITextField?
    
    var emailTextField: UITextField?
    
    var linkedInTextField: UITextField?
    
    // Text field tag: key dictionary
    var keyField: [Int: String]?
    
    // Constraints related to animations
    var backTrailingConstraint: NSLayoutConstraint?
    
    // Toggles edit mode, changes UI components
    @IBAction func toggleEditMode(sender: AnyObject) {
        if inEditingMode{
            inEditingMode = false
            
            self.disableButtons()
            outOfEditModeAnimations()
            
            editButton.setTitle("Edit", forState: UIControlState.Normal)
            
            aboutTextView.editable = false
        }else{ // Put UI into edit mode
            inEditingMode = true
            
            self.disableButtons()
            intoEditModeAnimations()
            
            editButton.setTitle("Done", forState: UIControlState.Normal)
            
            aboutTextView.editable = true
        }
    }
    
    // Goes back to the previous view controller
    @IBAction func goBack(sender: AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // If true, edit button is present
    var allowsEditMode: Bool?
    
    var inEditingMode: Bool = false
    
    // User that is to be displayed on this view controller
    var user: PFUser?
    
    override func viewDidLoad(){
        setupGestures()
        displayUser(user!)
        changeButtons()
        
        if allowsEditMode!{
            addEditorView()
        }
        
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
        
        // Change info views
        contactInfoView.layer.cornerRadius = contactInfoView.frame.size.width/2
        contactInfoView.clipsToBounds = true
        
        linkedInView.layer.cornerRadius = linkedInView.frame.size.width/2
        linkedInView.clipsToBounds = true
        
        otherLinksView.layer.cornerRadius = otherLinksView.frame.size.width/2
        otherLinksView.clipsToBounds = true
        
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
            backTrailingConstraint = NSLayoutConstraint(item: backButton, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0)
            
            self.view.addConstraint(backTopConstraint)
            self.view.addConstraint(backTrailingConstraint!)
            
            // Add constraints to the back button
            let editTopConstraint = NSLayoutConstraint(item: editButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .TopMargin, multiplier: 1.0, constant: 24.0)
            let editLeadingConstraint = NSLayoutConstraint(item: editButton, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .LeadingMargin, multiplier: 1.0, constant: 0.0)
            
            self.view.addConstraint(editTopConstraint)
            self.view.addConstraint(editLeadingConstraint)
        }
    }
    
    // Sets up gestures for this view controller
    func setupGestures(){
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: Selector("closeKeyboards"))
        self.view.addGestureRecognizer(tapScreenGesture)
    }
    
    // Close open keyboards
    func closeKeyboards(){
        self.view.endEditing(true)
    }
    
    func outOfEditModeAnimations(){
        
        // Animate back button
        self.backButton.hidden = false
        
        self.backTrailingConstraint?.constant = 0.0
        self.view.setNeedsUpdateConstraints()
        let backButtonAnimation = { () -> Void in
            self.view.layoutIfNeeded()
        }
        UIView.animateWithDuration(0.5, animations: backButtonAnimation) { (success: Bool) -> Void in
            if success{
                self.enableButtons()
            }
        }
        
        // Animate info views
        // i) linkedInView
        UIView.animateWithDuration(0.5) { () -> Void in
            self.linkedInView.transform = CGAffineTransformIdentity
        }
        // ii) contactInfoView
        UIView.animateWithDuration(0.5) { () -> Void in
            self.contactInfoView.transform = CGAffineTransformIdentity
        }
        // iii) otherLinksView
        UIView.animateWithDuration(0.5) { () -> Void in
            self.otherLinksView.transform = CGAffineTransformIdentity
        }
        
        // Animate editor view
        UIView.animateWithDuration(0.5) { () -> Void in
            self.editorView?.transform = CGAffineTransformIdentity
        }
    }
    
    func intoEditModeAnimations(){
        // Animate back button
        self.backTrailingConstraint?.constant += (self.view.frame.width - self.backButton.center.x) + self.backButton.frame.width
        self.view.setNeedsUpdateConstraints()
        let backButtonAnimation = { () -> Void in
            self.view.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(0.5, animations: backButtonAnimation) { (success: Bool) -> Void in
            if success{
                self.backButton.hidden = true
                self.enableButtons()
            }
        }
        
        // Animate info views
        // i) linkedInView
        horizontalTranslateRotateAnimation(self.linkedInView, duration: 0.5, delay: 0.0, tx: -240, degrees: 180, completion: nil)
        // ii) contactInfoView
        horizontalTranslateRotateAnimation(self.contactInfoView, duration: 0.5, delay: 0.0, tx: -480, degrees: 180, completion: nil)
        // iii) otherLinksView
        horizontalTranslateRotateAnimation(self.otherLinksView, duration: 0.5, delay: 0.0, tx: 240, degrees: 180, completion: nil)
        
        // Animate editor view
        UIView.animateWithDuration(0.5) { () -> Void in
            self.editorView!.transform = CGAffineTransformTranslate(self.editorView!.transform, 0.0, -1.0 * (self.view.frame.height/2.0 + 90))
        }
    }
    
    func disableButtons(){
        self.editButton.enabled = false
        self.backButton.enabled = false
    }
    
    func enableButtons(){
        self.editButton.enabled = true
        self.backButton.enabled = true
    }
    
    func degreesToRadians(degrees: CGFloat) -> CGFloat{
        let PIFloat = CGFloat(M_PI)
        return (PIFloat * degrees / 180.0) as CGFloat
    }
    
    // Performs a horizontal translation, and rotation on the given view
    func horizontalTranslateRotateAnimation(view: UIView, duration: Double, delay: Double, tx: CGFloat, degrees: CGFloat, completion: ((Bool) -> Void)?) -> CGAffineTransform{
        
        let animation = {
            let translate = CGAffineTransformTranslate(view.transform, tx, 0.0)
            view.transform = CGAffineTransformRotate(translate, self.degreesToRadians(degrees))
        }
        
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveLinear, animations: animation, completion: completion)
        
        return view.transform
    }
    
    func addEditorView(){
        
        let user = PFUser.currentUser()
        
        // Main editor view
        editorView = UIView(frame: CGRectMake(0, self.view.frame.height, 300, 180))
        editorView!.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        editorView!.center.x = self.view.frame.width/2.0
        editorView!.layer.cornerRadius = 6.0
        
        // Phone number
        let phoneImageView = UIImageView(frame: CGRectMake(10, 10, 30, 30))
        phoneImageView.image = UIImage(named: "PhoneIcon")
        
        phoneNumberTextField = UITextField(frame: CGRectMake(50, 10, 240, 30))
        phoneNumberTextField!.borderStyle = UITextBorderStyle.RoundedRect
        phoneNumberTextField!.placeholder = "Phone Number"
        phoneNumberTextField!.tag = 0
        phoneNumberTextField?.delegate = self
        if let text = user?.valueForKey("phoneNumber") as! String?{
            phoneNumberTextField!.text = text
        }
        
        // Email
        let emailImageView = UIImageView(frame: CGRectMake(10, 70, 30, 30))
        emailImageView.image = UIImage(named: "EmailIcon")
        
        emailTextField = UITextField(frame: CGRectMake(50, 70, 240, 30))
        emailTextField!.borderStyle = UITextBorderStyle.RoundedRect
        emailTextField!.placeholder = "Email"
        emailTextField!.tag = 1
        emailTextField!.delegate = self
        if let text = user?.valueForKey("email") as! String?{
            emailTextField!.text = text
        }
        
        // LinkedIn
        linkedInTextField = UITextField(frame: CGRectMake(50, 130, 240, 30))
        linkedInTextField!.borderStyle = UITextBorderStyle.RoundedRect
        linkedInTextField!.placeholder = "LinkedIn"
        linkedInTextField!.tag = 2
        linkedInTextField!.delegate = self
        if let text = user?.valueForKey("linkedIn") as! String?{
            linkedInTextField!.text = text
        }
        
        // Create text field, key dictionary
        keyField = [phoneNumberTextField!.tag: "phoneNumber", emailTextField!.tag: "email", linkedInTextField!.tag: "linkedIn"]
        
        // Now add all components to editor view
        editorView!.addSubview(phoneImageView)
        editorView!.addSubview(phoneNumberTextField!)
        
        editorView!.addSubview(emailImageView)
        editorView!.addSubview(emailTextField!)
        
        editorView!.addSubview(linkedInTextField!)
        
        self.view.addSubview(editorView!)
    }
    
}

extension UserViewController: UITextFieldDelegate{
    // Save the contents of the text field that has just been edited
    func textFieldDidEndEditing(textField: UITextField) {
        let key = keyField![textField.tag]
        let contents = textField.text
        
        let user = PFUser.currentUser()
        user?.setValue(contents!, forKey: key!)
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if error != nil{
                print("\(error?.localizedDescription)")
            }
            
            if success{
                print("Succesfully saved for  \(key!) field.")
            }else{
                print("Unable to save for \(key!) field.")
            }
        })
    }
}