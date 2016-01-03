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
}