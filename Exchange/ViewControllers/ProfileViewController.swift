//
//  ProfileViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/2/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    // Text Field outlets
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var companyTextField: UITextField!
    
    @IBOutlet weak var jobPositionTextField: UITextField!
    
    @IBOutlet weak var linkedInTextField: UITextField!
    
    // The text field that is currently being edited
    
    var textFieldBeingEdited: UITextField?
    
    // Allows user to test their profile appearance
    
    @IBAction func testUserProfile(sender: AnyObject) {
        performSegueWithIdentifier("TestProfile", sender: self)
    }
    
    // Array of text fields, and their respective key
    var textFields: [(UITextField, String)] = []
    
    var photoSelectorHelper: PhotoSelectorHelper?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        profileImageView.userInteractionEnabled = true
        
        setTextFieldProperties()
        setupProfile()
        setupGestures()
        
        // Adds keyboard appearance to notification center
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupProfile(){
        // Get instance of current user
        let user = PFUser.currentUser()
        
        // Load name of user
        if let firstName = user?.valueForKey("firstName") as! String?, lastName = user?.valueForKey("lastName") as! String?{
            nameLabel.text = firstName + " " + lastName
        }
        
        if let imageFile = user?.valueForKey("profilePicture") as! PFFile?{
            imageFile.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                if error != nil{
                    print("\(error?.localizedDescription)")
                }
                
                if let data = data{
                    let image = UIImage(data: data)
                    self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFit
                    self.profileImageView.image = image
                }else{
                    print("Unable to receive data for image.")
                }
            })
        }
        
    }
    
    func setupGestures(){
        
        let tapProfileImage = UITapGestureRecognizer(target: self, action: Selector("changeProfileImage"))
        let tapScreen = UITapGestureRecognizer(target: self, action: Selector("closeTextField"))
        
        profileImageView.addGestureRecognizer(tapProfileImage)
        self.view.addGestureRecognizer(tapScreen)
        
    }
    
    // Sets the properties of all the text fields
    func setTextFieldProperties(){
        
        textFields = [(phoneNumberTextField, "phoneNumber"),
            (emailTextField, "email"),
            (companyTextField, "companyName"),
            (jobPositionTextField, "jobPosition"),
            (linkedInTextField, "linkedIn")]
        
        // Iterates through the array of text fields
        for (index, value) in textFields.enumerate(){
            // First set delegate and tag
            let textField = value.0
            let key = value.1
            
            textField.delegate = self
            textField.tag = index
            
            // Now if the current user has info previously filled in, add to field
            let user = PFUser.currentUser()
            
            if let text = user?.valueForKey(key){
                textField.text = text as! String
            }
        }
    }
    
    // Called when the user taps their profile image
    func changeProfileImage(){
        photoSelectorHelper = PhotoSelectorHelper(viewController: self, callback: { (image: UIImage?) -> Void in
            if let image = image{
                // Set the image
                self.profileImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.profileImageView.image = image
                
                // Now save the new image in parse backend
                let imageData = UIImageJPEGRepresentation(image, 0.8)
                let imageFile = PFFile(data: imageData!)
                PFUser.currentUser()?.setValue(imageFile, forKey: "profilePicture")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error != nil{
                        print("\(error?.localizedDescription)")
                    }
                    if success{
                        print("Profile image saved succesfully")
                    }else{
                        print("Unable to save image")
                    }
                })
            }else{
                print("Unable to get image from photo selection.")
            }
        })
    }
    
    // Closes any first responders
    func closeTextField(){
        self.view.endEditing(true)
    }
    
    // Caled by selector when keyboard is about to appear
    func keyboardWillShow(notification: NSNotification){
        print("Keyboard will show.")
        
        if let userInfo = notification.userInfo{
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
                let keyboardHeight = keyboardSize.height
                
                
            }else{
                print("No UIKeyboardFramUserInfoKey value in user info dictionary.")
            }
        }else{
            print("No user dictionary info received.")
        }
        
    }
    
    func keyboardWillHide(notifcation: NSNotification){
        print("Keyboard will hide.")
        
        
    }
    
    // Saves the content of a text field
    func saveContentOf(textFieldKey: String, value: String){
        let user = PFUser.currentUser()
        
        user?.setValue(value, forKey: textFieldKey)
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if error != nil{
                print("\(error?.localizedDescription)")
            }
            
            if success{
                print("\(value) saved for key \(textFieldKey) successfully.")
            }else{
                print("Unable to save value for \(textFieldKey).")
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TestProfile"{
            let viewController = segue.destinationViewController as! UserProfileViewController
            viewController.user = PFUser.currentUser()
        }
    }
    
}

extension ProfileViewController: UITextFieldDelegate{
    // Called when the text fields are no longer being edited
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text
        let textFieldKey = textFields[textField.tag].1
        
        // If there is text in the text field
        if let text = text{
            saveContentOf(textFieldKey, value: text)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("\(textFields[textField.tag].1) text field is being edited.")
        
        textFieldBeingEdited = textField
    }
}
