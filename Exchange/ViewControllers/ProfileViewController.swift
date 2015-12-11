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
    
    
    var photoSelectorHelper: PhotoSelectorHelper?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        profileImageView.userInteractionEnabled = true
        
        setupProfile()
        setupGestures()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupProfile(){
        // Get instance of current user
        let user = PFUser.currentUser()
        
        // Load name of user
        let firstName = user?.valueForKey("firstName")! as! String
        let lastName = user?.valueForKey("lastName")! as! String
        nameLabel.text = firstName + " " + lastName
        
        if let imageFile = user?.valueForKey("profilePicture")! as! PFFile?{
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
        /*let longPressCard = UILongPressGestureRecognizer(target: self, action: Selector("deleteCardImage"))
        let tapCard = UITapGestureRecognizer(target: self, action: Selector("setCardImage"))
        
        cardImageButton.addGestureRecognizer(longPressCard)
        cardImageButton.addGestureRecognizer(tapCard)*/
        
        let tapProfileImage = UITapGestureRecognizer(target: self, action: Selector("changeProfileImage"))
        
        profileImageView.addGestureRecognizer(tapProfileImage)
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
    
    
    
}
