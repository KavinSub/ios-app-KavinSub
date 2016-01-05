//
//  ProfileCell.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/10/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ProfileCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubviews()
    }
    
    func addSubviews(){
        profileImageView.frame = CGRectMake(10, 10, 110, 110)
        nameLabel.frame = CGRectMake(140, self.frame.height/2.0 - 10, 230, 20)
    }
    
    func setProfileImage(image: UIImage?){
        if let image = image{
            profileImageView.image = image
        }else{
            // TODO: Load default image
            profileImageView.image = UIImage(named: "EmailIcon")
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2.0
        profileImageView.clipsToBounds = true
        
        profileImageView.layer.borderWidth = 3.0
        profileImageView.layer.borderColor = UIElementProperties.textColor.CGColor
    }
    
    func setName(firstName: String?, lastName: String?){
        var name = "None"
        
        if firstName != nil && lastName != nil{
            name = "\(firstName!) \(lastName!)"
        }else if firstName != nil{
            name = "\(firstName!)"
        }else if lastName != nil{
            name = "\(lastName!)"
        }
        
        nameLabel.text = name
    }
    
}
