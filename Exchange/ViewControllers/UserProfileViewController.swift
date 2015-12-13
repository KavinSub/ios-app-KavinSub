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
    
    // Outlets of the info labels
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var companyLabel: UILabel!
    
    @IBOutlet weak var jobPositionLabel: UILabel!
    
    @IBOutlet weak var linkedInLabel: UILabel!
    
    var labels: [(UILabel, String, String)] = []
    
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
        
        labels =
        [(phoneNumberLabel, "phoneNumber", "Phone Number"),
        (emailLabel, "email", "Email"),
        (companyLabel, "companyName", "Company"),
        (jobPositionLabel, "jobPosition", "Position"),
        (linkedInLabel, "linkedIn", "LinkedIn")]
        
        for (label, key, fieldName) in labels{
            if let text = user.valueForKey(key) as! String?{
                label.text = "\(fieldName): \(text)"
            }else{
                label.text = "\(fieldName): N/A"
            }
        }
    }
    
}
