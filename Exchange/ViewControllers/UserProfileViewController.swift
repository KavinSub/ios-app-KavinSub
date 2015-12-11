//
//  UserProfileViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/10/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    // Reference to the user whose profile is being displayed
    var user: PFUser?
    
    override func viewDidLoad(){
        displayUser(user!)
    }
    
    func displayUser(user: PFUser){
        // Set name
        let firstName = user.valueForKey("firstName") as! String
        let lastName = user.valueForKey("lastName") as! String
        
        nameLabel.text = "\(firstName) \(lastName)"
        
        // Set image
        let imageFile = user.valueForKey("profilePicture") as! PFFile
        do{
            let imageData = try imageFile.getData()
            let image = UIImage(data: imageData)
            profileImageView.image = image
        }catch{
            print("Unable to load image")
        }
    }
    
}
