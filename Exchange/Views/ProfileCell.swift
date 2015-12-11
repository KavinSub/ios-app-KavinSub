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
    @IBOutlet weak var dateLabel: UILabel!
    
    func setName(name: String){
        
        nameLabel.text = name
    }
    
    func setDate(date: String){
        dateLabel.text = date
    }
    
    func setProfileImage(image: UIImage){
        profileImageView.image = image
    }
}
