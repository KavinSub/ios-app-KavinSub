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

    
    @IBOutlet weak var phoneField: UITextField!
    
    var enteredNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestures()
        
        phoneField.backgroundColor = UIColor.whiteColor()
        
        let leftView = UILabel(frame: CGRectMake(10, 0, 7, 26))
        leftView.backgroundColor = UIColor.clearColor()
        
        phoneField.leftView = leftView
        phoneField.leftViewMode = UITextFieldViewMode.Always
        phoneField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendInfo(sender: AnyObject) {
        if MFMessageComposeViewController.canSendText(){
            let message = MFMessageComposeViewController()
            
            let user = PFUser.currentUser()!
            
            var messageBody = ""
            
            if let number = user.valueForKey("phoneNumber") as! String?{
                messageBody += "Phone number: \(number)\n"
            }
            
            if let email = user.valueForKey("email") as! String?{
                messageBody += "Email: \(email)\n"
            }
            
            if let linkedIn = user.valueForKey("linkedIn") as! String?{
                messageBody += "LinkedIn: https://www.linkedin.com/in/\(linkedIn)\n"
            }
            
            message.body = messageBody
            
            message.recipients = [enteredNumber]
            
            message.messageComposeDelegate = self
            
            self.presentViewController(message, animated: true, completion: nil)
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
        
        textField.text = enteredNumber
        
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIElementProperties.backgroundColor.CGColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.characters.count >= 0 && textField.text?.characters.count <= 10{
            enteredNumber = stripNonNumbers(textField.text! ?? "")
        }else{
            enteredNumber = stripNonNumbers(textField.text!.substringToIndex(textField.text!.startIndex.advancedBy(10)))
        }
        print("\(enteredNumber)")
        textField.text = formatNumber(enteredNumber)
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