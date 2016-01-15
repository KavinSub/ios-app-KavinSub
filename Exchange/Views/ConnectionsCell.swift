//
//  ConnectionsCell.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/8/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ConnectionsCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var jobLabel: UILabel!
    
    func setProfileImage(imageFile: PFFile?){
        if let imageFile = imageFile{
            
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                if let data = data{
                    let image = UIImage(data: data)
                    self.profileImageView.image = image
                    
                    self.contentView.setNeedsLayout()
                }else{
                    self.profileImageView.image = UIImage(named: "Default Profile")
                }
            })
        }else{
            self.profileImageView.image = UIImage(named: "Default Profile")
        }
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2.0
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.borderColor = UIElementProperties.textColor.CGColor
        self.profileImageView.layer.borderWidth = 1.0
    }
    
    func setName(firstName: String, lastName: String){
        nameLabel.text = "\(firstName) \(lastName)"
        
    }
    
    func setJob(position: String, company: String){
        if position == "" && company == ""{
            jobLabel.text = ""
        }else if position == ""{
            jobLabel.text = "Works at \(company)"
        }else if company == ""{
            jobLabel.text = "Works as \(position)"
        }else{
            jobLabel.text = "\(position) at \(company)"
        }
    }
    
}
