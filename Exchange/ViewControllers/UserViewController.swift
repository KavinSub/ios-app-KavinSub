//
//  UserViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/2/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class UserViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var contactInfoView: UIView!
    
    @IBOutlet weak var linkedInView: UIView!
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var leftTextFieldView: UIView!
    
    @IBOutlet weak var rightTextFieldView: UIView!
    
    var infoView: InfoView?
    
    // All views related to the editor view component
    var editorView: UIView?
    
    var phoneNumberTextField: UITextField?
    
    var emailTextField: UITextField?
    
    var linkedInTextField: UITextField?
    
    // Text field tag: key dictionary
    var keyField: [Int: String]?
    
    // Constraints related to animations
    var backTrailingConstraint: NSLayoutConstraint?
    
    // Keyboard constants
    var keyboardHeight: CGFloat?
    
    var keyboardAnimationTime: Double?
    
    
    //*************************************** View Actions Code *******************************************
    
    // Toggles edit mode, changes UI components
    @IBAction func toggleEditMode(sender: AnyObject) {
        if inEditingMode{ // Put UI into show mode
            inEditingMode = false
            
            contactInfoView.userInteractionEnabled = true
            
            self.disableButtons()
            outOfEditModeAnimations()
            
            editButton.setTitle("Edit", forState: UIControlState.Normal)
            
            aboutTextView.editable = false
            
            saveUser()
        }else{ // Put UI into edit mode
            inEditingMode = true
            
            contactInfoView.userInteractionEnabled = false
            
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
        addInfoView()
        setUpImageView()
        
        aboutTextView.delegate = self
        
        if allowsEditMode!{
            addEditorView()
        }
        
    }
    
    func saveUser(){
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if error != nil{
                print("\(error?.localizedDescription)")
            }
            
            if success{
                print("Succesfully new user values.")
            }else{
                print("Unable to save user values.")
            }
            
            // The labels of the info view should be updated
            self.infoView?.updateLabels()
        })
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
        
        // Make info views circular with a border
        contactInfoView.layer.cornerRadius = contactInfoView.frame.size.width/2
        contactInfoView.clipsToBounds = true
        
        linkedInView.layer.cornerRadius = linkedInView.frame.size.width/2
        linkedInView.clipsToBounds = true
        
        // Add content to text view
        if let text = user.valueForKey("about") as! String?{
            aboutTextView.text = text
        }
        aboutTextView.editable = false
    }
    
    func addInfoView(){
        infoView = InfoView()
        
        infoView!.user = user
        
        infoView?.viewController = self
        
        infoView!.frame = CGRectMake(0, 0, 300, 180)
        infoView!.center.x = self.view.center.x
        infoView!.center.y = self.nameLabel.center.y + self.nameLabel.frame.height + 20 + (self.infoView?.frame.height)!/2.0
        
        let rotationTransform = CATransform3DRotate(infoView!.layer.transform, CGFloat(M_PI) * -0.5, 0.0, 1.0, 0.0)
        infoView?.layer.transform = rotationTransform
        infoView!.hidden = true
        
        self.view.addSubview(infoView!)
    }
    
    
    //*************************************** Component Interaction Code *******************************************
    
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
        }else{
            // Hide edit button, disable interaction
            self.editButton.userInteractionEnabled = false
            self.editButton.hidden = true
            
            // Place the back button in the proper position
            let backTopConstraint = NSLayoutConstraint(item: backButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 24.0)
            let backLeadingConstraint = NSLayoutConstraint(item: backButton, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
            
            self.view.addConstraint(backTopConstraint)
            self.view.addConstraint(backLeadingConstraint)
        }
    }
    
    // Sets up gestures for this view controller
    func setupGestures(){
        
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: Selector("closeKeyboards"))
        self.view.addGestureRecognizer(tapScreenGesture)
        
        // Gesture for opening contact information
        let tapContactInfoGesture = UITapGestureRecognizer(target: self, action: Selector("openContactInformation"))
        contactInfoView.addGestureRecognizer(tapContactInfoGesture)
        
        // Gesture for opening linkedIn profile
        let tapLinkedInGesture = UITapGestureRecognizer(target: self, action: Selector("openLinkedIn"))
        linkedInView.addGestureRecognizer(tapLinkedInGesture)
    }
    
    // Close open keyboards
    func closeKeyboards(){
            self.view.endEditing(false)
    }
    
    func disableButtons(){
        self.editButton.enabled = false
        self.backButton.enabled = false
    }
    
    func enableButtons(){
        self.editButton.enabled = true
        self.backButton.enabled = true
    }
    
    func disableInteraction(){
        contactInfoView.userInteractionEnabled = false
        linkedInView.userInteractionEnabled = false
    }
    
    func enableInteraction(){
        contactInfoView.userInteractionEnabled = true
        linkedInView.userInteractionEnabled = true
    }
    
    // Open linked in profile
    func openLinkedIn(){
        let user = PFUser.currentUser()!
        
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
    
    func setUpImageView(){
        // This constraint is added so the image moves up with the rest of the view
        let profileTopConstraint = NSLayoutConstraint(item: profileImageView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 50.0)
        
        self.view.addConstraint(profileTopConstraint)
    }

    
    //*************************************** Animation Code *******************************************
    
    
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
        
        // Animate editor view
        UIView.animateWithDuration(0.5) { () -> Void in
            self.editorView!.center.y = self.view.frame.height + self.editorView!.frame.height/2.0
        }
        
        // Animate text field bars back
        // i) Left field bar
        UIView.animateWithDuration(0.5) { () -> Void in
            self.leftTextFieldView.transform = CGAffineTransformIdentity
        }
        
        // ii) Right field bar
        UIView.animateWithDuration(0.5) { () -> Void in
            self.rightTextFieldView.transform = CGAffineTransformIdentity
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
        horizontalTranslateRotateAnimation(self.contactInfoView, duration: 0.5, delay: 0.0, tx: 240, degrees: 180, completion: nil)
        
        // Animate editor view
        UIView.animateWithDuration(0.5) { () -> Void in
            self.editorView!.center.y = self.nameLabel.center.y + self.nameLabel.frame.height + 20 + (self.editorView?.frame.height)!/2.0
        }
        
        // Animate text field bars away
        // i) left field bar
        UIView.animateWithDuration(0.5) { () -> Void in
            self.leftTextFieldView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * self.leftTextFieldView.frame.width, 0.0)
        }
        
        // ii) Right field bar
        UIView.animateWithDuration(0.5) { () -> Void in
            self.rightTextFieldView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.rightTextFieldView.frame.width, 0.0)
        }
    }
    
    // Code to close info view
    func closeInfoView(){
        
        // Animate edit button if applicable
        if allowsEditMode!{
            editButton.hidden = false
            editButton.userInteractionEnabled = false
            let editButtonAnimation = { () -> Void in
                self.editButton.transform = CGAffineTransformIdentity
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: editButtonAnimation, completion: { (success: Bool) -> Void in
                self.editButton.userInteractionEnabled = true
            })
        }
        
        // Animate linkedIn circle
        UIView.animateWithDuration(0.5) { () -> Void in
            self.linkedInView.transform = CGAffineTransformIdentity
        }
        
        // Animate info view out of the way
        let infoViewAnimation = { () -> Void in
            self.infoView!.layer.transform = CATransform3DRotate(self.infoView!.layer.transform, CGFloat(M_PI) * -0.5, 0.0, 1.0, 0.0)
        }
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: infoViewAnimation, completion: nil)
        
        // Animate contact info circle
        let animation = {
            self.contactInfoView!.transform = CGAffineTransformIdentity
        }
        
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveLinear, animations: animation) { (success: Bool) -> Void in
            self.enableInteraction()
        }
        
        
    }
    
    // Open contact information view
    func openContactInformation(){
        print("Show contact info")
        
        disableInteraction()
        
        // Animate editButton out of way
        if allowsEditMode!{
            let editButtonAnimation =  { () -> Void in
                self.editButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * (self.editButton.frame.width + self.editButton.center.x), 0.0)
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn, animations: editButtonAnimation, completion: { (success: Bool) -> Void in
                self.editButton.hidden = true
            })
        }
        
        // Animate circles out of way
        // i) LinkedIn view
        UIView.animateWithDuration(0.5) { () -> Void in
            self.horizontalTranslateRotateAnimation(self.linkedInView, duration: 0.5, delay: 0.0, tx: -240, degrees: 180, completion: nil)
        }
        
        // ii) Contact info view
        UIView.animateWithDuration(0.3) { () -> Void in
            let translateTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * (self.contactInfoView.center.x - self.view.center.x), 0.0)
            let rotateTransform = CGAffineTransformRotate(translateTransform, self.degreesToRadians(180.0))
            let scaleTransform = CGAffineTransformScale(rotateTransform, 0.01, 0.01)
            self.contactInfoView.transform = scaleTransform
        }
        
        // Open up information
        infoView!.hidden = false
        let infoViewAnimation = {
            self.infoView!.layer.transform = CATransform3DRotate(self.infoView!.layer.transform, CGFloat(M_PI) * 0.5, 0.0, 1.0, 0.0)
        }
        
        UIView.animateWithDuration(0.2, delay: 0.3, options: .CurveLinear, animations: infoViewAnimation, completion: nil)
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
    
    //*************************************** Editor Code *******************************************
    
    // Creates, and adds the editor view. 
    // TODO: This function is massive. Should be in separate view class.
    func addEditorView(){
    
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
        linkedInTextField!.placeholder = "LinkedIn (Just the extension)"
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
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.center.y += (40)
        }
    }
    
    // Push up view ever so slightly
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.center.y -= (40)
        }
    }
}

extension UserViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(textView: UITextView) {
        print("Editing begins")

        let animation = { () -> Void in
            self.view.center.y -= (216)
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: animation, completion: nil)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("Editing ends")
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.center.y += (216)
        }
        
        let user = PFUser.currentUser()!
        
        user.setValue(textView.text, forKey: "about")
    }
    

}