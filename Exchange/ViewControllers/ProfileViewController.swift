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
    
    @IBOutlet weak var cardImageButton: UIButton!
    
    var photoSelectorHelper: PhotoSelectorHelper?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
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
        
        // Load profile image
        if let imageFile = user?.valueForKey("profilePicture") as! PFFile?{
            imageFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                let image = UIImage(data: data!)
                self.profileImageView.image = image
            }
        }
        
        //let cardImageFile = user?.valueForKey("cardFile") as! PFFile
        if let cardImageFile = user?.valueForKey("cardFile") as! PFFile?{
            cardImageFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                let image = UIImage(data: data!)
                self.cardImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                self.cardImageButton.setBackgroundImage(image, forState: UIControlState.Normal)
                print("card image set")
            }
        }
    }
    
    func setupGestures(){
        let longPressCard = UILongPressGestureRecognizer(target: self, action: Selector("deleteCardImage"))
        let tapCard = UITapGestureRecognizer(target: self, action: Selector("setCardImage"))
        
        cardImageButton.addGestureRecognizer(longPressCard)
        cardImageButton.addGestureRecognizer(tapCard)
    }
    
    
    func deleteCardImage(){
        print("Long Press detected on card")
    }
    
    // Set the new image, in parse backend and on device
    func setCardImage(){
        photoSelectorHelper = PhotoSelectorHelper(viewController: self){(image: UIImage?) in
            // Set device image
            self.cardImageButton.imageView?.image = image
            
            // Set image file in backend
            let user = PFUser.currentUser()
            let imageData = UIImageJPEGRepresentation(image!, 0.8)
            let imageFile = PFFile(data: imageData!)
            
            user?.setValue(imageFile, forKey: "cardFile")
            user?.saveInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
                if result == true{
                    print("Card Image saved succesfully")
                }else{
                    print("Card Image not saved properly")
                }
            })
        }
    }
}
