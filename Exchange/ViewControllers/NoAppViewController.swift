//
//  NoAppViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/9/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import MessageUI
import Parse

class NoAppViewController: UIViewController{

    @IBOutlet weak var phoneEmailControl: UISegmentedControl!
    
    @IBAction func toggleField(sender: UISegmentedControl) {
        // 0 -> phoneField
        // 1 -> emailField
        // By default, phoneField is initial state
        let state = sender.selectedSegmentIndex
        
        if state == 1{
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.phoneField.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * (self.phoneField.frame.width + 30.0), 0.0)
                
                self.emailField.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.phoneField.center.x - self.emailField.center.x, 0.0)
            })
        }else if state == 0{
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.phoneField.transform = CGAffineTransformIdentity
                self.emailField.transform = CGAffineTransformIdentity
            })
        }
    }
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    var enteredNumber = ""
    
    var enteredEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestures()
        
        // i) Phone Field
        phoneField.backgroundColor = UIColor.whiteColor()
        
        let leftView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        leftView.backgroundColor = UIColor.clearColor()
        
        phoneField.leftView = leftView
        phoneField.leftViewMode = UITextFieldViewMode.Always
        phoneField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        phoneField.tag = 0
        
        // ii) Email Field
        
        let emailLeftView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        leftView.backgroundColor = UIColor.clearColor()
        
        emailField.leftView = emailLeftView
        emailField.leftViewMode = UITextFieldViewMode.Always
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        emailField.tag = 1
        
        // iii) PhoneEmail toggle control
        phoneEmailControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIElementProperties.textColor], forState: UIControlState.Normal)
        phoneEmailControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIElementProperties.textColor], forState: UIControlState.Selected)
        
        
    }
    
    
    @IBAction func sendInfo(sender: AnyObject) {
        
        let user = PFUser.currentUser()!
        
        var messageBody = ""
        
        let firstName = user.valueForKey("firstName") as! String? ?? ""
        let lastName = user.valueForKey("lastName") as! String? ?? ""
        
        if firstName != "" && lastName != "" {
            messageBody += "Hey it's \(firstName) \(lastName). It was great meeting you. Here's my contact info.\n"
        }
        
        if let number = user.valueForKey("phoneNumber") as! String?{
            messageBody += "Phone number: \(number)\n"
        }
        
        if let email = user.valueForKey("email") as! String?{
            messageBody += "Email: \(email)\n"
        }
        
        if let linkedIn = user.valueForKey("linkedIn") as! String?{
            messageBody += "LinkedIn: https://www.linkedin.com/in/\(linkedIn)\n"
        }
        
        if phoneEmailControl.selectedSegmentIndex == 0{
            if MFMessageComposeViewController.canSendText(){ // TODO: Give user warning if unable to send text/email
                
                let message = MFMessageComposeViewController()
            
                message.body = messageBody
                
                message.recipients = [stripNonNumbers(phoneField.text!)]
                
                message.messageComposeDelegate = self
                
                self.presentViewController(message, animated: true, completion: nil)
            }
        }else if phoneEmailControl.selectedSegmentIndex == 1{
            if MFMailComposeViewController.canSendMail(){
                let mail = MFMailComposeViewController()
                
                mail.setMessageBody(messageBody, isHTML: false)
                
                mail.setToRecipients([emailField.text!])
                
                mail.mailComposeDelegate = self
                
                self.presentViewController(mail, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addGestures(){
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: Selector("closeKeyboards"))
        self.view.addGestureRecognizer(tapScreenGesture)
    }
    
    func closeKeyboards(){
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Formats a number into (xxx) xxx-xxxx
    func formatNumber(number: String) -> String{
        let count = number.characters.count
        
        let index = number.startIndex
        
        if count == 0{
            return ""
        }else if count >= 1 && count < 3{
            return String(format: "(%@", arguments: [number.substringToIndex(index.advancedBy(count))])
        }else if count == 3{
            return String(format: "(%@)", arguments: [number.substringToIndex(index.advancedBy(3))])
        }else if count > 3 && count <= 6{
            return String(format: "(%@) %@", arguments: [number.substringToIndex(index.advancedBy(3)), number.substringWithRange(Range(start: index.advancedBy(3), end: index.advancedBy(count)))])
        }else{
            return String(format: "(%@) %@-%@", arguments: [number.substringToIndex(index.advancedBy(3)), number.substringWithRange(Range(start: index.advancedBy(3), end: index.advancedBy(6))), number.substringWithRange(Range(start: index.advancedBy(6), end: index.advancedBy(count)))])
        }
    }
    
    
    // Keeps only the numbers of the string
    func stripNonNumbers(string: String) -> String{
        let numberSet: Set<Character> = Set("0123456789".characters)
        let characters = Array(string.characters)
        
        var returnable = ""
        
        for character in characters{
            if numberSet.contains(character){
                returnable += String(character)
            }
        }
        
        return returnable
    }
}

extension NoAppViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 0{
            textField.text = enteredNumber
        }
        
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIElementProperties.backgroundColor.CGColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 0{
            if textField.text?.characters.count >= 0 && textField.text?.characters.count <= 10{
                enteredNumber = stripNonNumbers(textField.text! ?? "")
            }else{
                enteredNumber = stripNonNumbers(textField.text!.substringToIndex(textField.text!.startIndex.advancedBy(10)))
            }
            print("\(enteredNumber)")
            textField.text = formatNumber(enteredNumber)
        }else if textField.tag == 1{
            enteredEmail = textField.text! ?? ""
        }
        textField.layer.borderWidth = 0.0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NoAppViewController: MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension NoAppViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}