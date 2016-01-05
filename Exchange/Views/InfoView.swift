//
//  InfoView.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/3/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class InfoView: UIView {
    
    // Reference to enclosing view controller
    var viewController: UserViewController?
    
    // References to Subviews
    var phoneNumberLabel: UILabel?
    var emailLabel: UILabel?
    
    var doneButton: UIButton?
    
    var user: PFUser?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        modifyMainView()
        addSubviews()
    }
    
    // Modifies main view parameters
    func modifyMainView(){
        self.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        self.layer.cornerRadius = 6.0
        self.layer.borderColor = UIElementProperties.textColor.CGColor
        self.layer.borderWidth = 3.0
        
    }
    
    func addSubviews(){
        
        // Phone Number
        let phoneIconImageView = UIImageView(frame: CGRectMake(10, 30, 30, 30))
        phoneIconImageView.image = UIImage(named: "PhoneIcon")
        
        phoneNumberLabel = UILabel(frame: CGRectMake(50, 30, 240, 30))
        
        phoneNumberLabel!.adjustsFontSizeToFitWidth = true
        
        if let number = user!.valueForKey("phoneNumber") as! String?{
            phoneNumberLabel!.text = number
        }
        
        // Email
        let emailIconImageView = UIImageView(frame: CGRectMake(10, 120, 30, 30))
        emailIconImageView.image = UIImage(named: "EmailIcon")
        
        emailLabel = UILabel(frame: CGRectMake(50, 120, 240, 30))
        emailLabel!.adjustsFontSizeToFitWidth = true
        
        if let text = user!.valueForKey("email") as! String?{
            emailLabel!.text = text
        }
        
        // Done Button
        doneButton = UIButton(frame: CGRectMake(240, 10, 50, 30))
        doneButton!.setTitle("Done", forState: .Normal)
        doneButton!.setTitleColor(UIElementProperties.textColor, forState: .Normal)
        doneButton!.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15.0)
        doneButton?.addTarget(viewController, action: Selector("closeInfoView"), forControlEvents: UIControlEvents.TouchUpInside)
            
        // Add subviews
        self.addSubview(phoneIconImageView)
        self.addSubview(phoneNumberLabel!)
        
        self.addSubview(emailIconImageView)
        self.addSubview(emailLabel!)
        
        self.addSubview(doneButton!)
    }
    
    func updateLabels(){
        let user = PFUser.currentUser()!
        
        if let number = user.valueForKey("phoneNumber") as! String?{
            phoneNumberLabel!.text = number
        }else{
            phoneNumberLabel!.text = ""
        }
        
        if let text = user.valueForKey("email") as! String?{
            emailLabel!.text = text
        }else{
            emailLabel!.text = ""
        }
        
    }
    
}
