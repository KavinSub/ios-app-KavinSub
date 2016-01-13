//
//  OtherUserViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/11/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse
import Contacts
import ContactsUI


class OtherUserViewController: UIViewController {

    var inViewMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayUser()
        UIChanges()
        addGestures()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
        
    var user: PFUser?
    
    @IBOutlet weak var profileBackView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var linkedInButton: UIButton!
    @IBOutlet weak var contactInfoButton: UIButton!
    @IBOutlet weak var aboutTextView: UITextView!
    
    // Info View
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var phoneIcon: UIImageView!
    @IBOutlet weak var emailIcon: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBAction func showInfoView(sender: AnyObject) {
        if !inViewMode{
            inViewMode = true
            
            phoneLabel.text = (user!.valueForKey("phoneNumber") as! String?) ?? ""
            emailLabel.text = (user!.valueForKey("email") as! String?) ?? ""

            let animation = { () -> Void in
                self.linkedInButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.linkedInButton.frame.width, 0.0)
                self.contactInfoButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -2.0 * self.contactInfoButton.frame.width, 0.0)
                self.infoView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * self.infoView.frame.width, 0.0)
                self.aboutTextView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, 1.0 * self.infoView.frame.height - 20)
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: nil)
        }
    }
    
    @IBAction func hideInfoView(sender: AnyObject) {
        if inViewMode{
            inViewMode = false
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.linkedInButton.transform = CGAffineTransformIdentity
                self.contactInfoButton.transform = CGAffineTransformIdentity
                self.infoView.transform = CGAffineTransformIdentity
                self.aboutTextView.transform = CGAffineTransformIdentity
            })
        }
    }
    
    @IBAction func showLinkedIn(sender: AnyObject) {
        if let userExtension = user!.valueForKey("linkedIn") as! String?{
            let URL = "https://www.linkedin.com/in/\(userExtension)"
            
            let encodedURL = NSURL(string: URL)
            if let encodedURL = encodedURL{
                UIApplication.sharedApplication().openURL(encodedURL)
            }else{
                print("This url does not exist")
            }
        }else{
            print("User does not have a linkedIn")
        }
    }
    
    @IBAction func exportToContacts(sender: AnyObject) {
        let store = CNContactStore()
        
        let contact = CNMutableContact()
        contact.familyName = user!.valueForKey("lastName") as! String? ?? ""
        contact.givenName = user!.valueForKey("firstName") as! String? ?? ""
        
        let mainPhone = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: user!.valueForKey("phoneNumber") as! String? ?? ""))
        contact.phoneNumbers = [mainPhone]
        
        let workEmail = CNLabeledValue(label: CNLabelWork, value: user!.valueForKey("email") as! String? ?? "")
        contact.emailAddresses = [workEmail]
        
        let contactController = CNContactViewController(forUnknownContact: contact)
        contactController.contactStore = store
        contactController.delegate = self
        
        print("About to present contact UI.")
        
        self.navigationController?.pushViewController(contactController, animated: true)
    }
    
    
    
    func displayUser(){
        // i) Profile Picture
        if let imageFile = user?.valueForKey("profilePicture") as! PFFile?{
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                if error != nil{
                    print(error?.localizedDescription)
                }
                if let data = data{
                    self.profileImageView.image = UIImage(data: data)
                }
            })
        }
        
        // ii) Name
        let firstName = (user!.valueForKey("firstName") as! String?) ?? ""
        let lastName = (user!.valueForKey("lastName") as! String?) ?? ""
        
        nameLabel.text = "\(firstName) \(lastName)"
        
        // iii) Position
        let position = (user!.valueForKey("position") as! String?) ?? ""
        let company = (user!.valueForKey("company") as! String?) ?? ""
        if position == "" && company == ""{
            jobLabel.text = "Works at"
        }else if position == ""{
            jobLabel.text = "Works at \(company)"
        }else if company == ""{
            jobLabel.text = "Works as \(position)"
        }else{
            jobLabel.text = "\(position) at \(company)"
        }
        
        // iv) About
        aboutTextView.text = (user!.valueForKey("about") as! String?) ?? ""
        
    }
    
    func UIChanges(){
        profileImageView.layer.borderColor = UIElementProperties.textColor.CGColor
        
        phoneIcon.image = UIImage(named: "PhoneIcon")
        emailIcon.image = UIImage(named: "EmailIcon")
    }
    
    func addGestures(){
        let swipeContactGesture = UISwipeGestureRecognizer(target: self, action: Selector("showInfoView:"))
        swipeContactGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.contactInfoButton.addGestureRecognizer(swipeContactGesture)
        
        let swipeInfoGesture = UISwipeGestureRecognizer(target: self, action: Selector("hideInfoView:"))
        self.infoView.addGestureRecognizer(swipeInfoGesture)
    }
}

extension OtherUserViewController: CNContactViewControllerDelegate{
    func contactViewController(viewController: CNContactViewController, didCompleteWithContact contact: CNContact?) {
        if let nav = self.navigationController{
            nav.navigationBarHidden = true
        }
    }
}
