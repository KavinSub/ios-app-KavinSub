//
//  LoginViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/18/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import Google


// NOTE: userLoggedIn stored in NSUserDefaults. Is true if user has been authenticated
class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    
    @IBAction func facebookLoginButtonPressed(sender: AnyObject) {
        // Credit to http://swiftdeveloperblog.com/parse-login-with-facebook-account-example-in-swift/
        
        
        // Login asking for permissions
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"]) { (user: PFUser?, error: NSError?) -> Void in
            // Print an error if present
            if(error != nil){
                print("\(error?.localizedDescription)")
                return
            }
            
            print(user)
            
            // Now get user info
            if(FBSDKAccessToken.currentAccessToken() != nil){
                print("User logged in.")
                
                let requestParameters = ["fields": "id, email, first_name, last_name"]
                let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
                
                userDetails.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
                    if error != nil{
                        print(error.localizedDescription)
                        return
                    }
                    
                    // We now have the info of the user object as result
                    if let result = result{
                        // Save the user info in user object fields
                        self.saveResult(result)
                        // Now get the profile picture
                        self.saveProfilePicture(result["id"] as! String)
                        
                        let user = PFUser.currentUser()!
                        
                        do{
                           try user.save()
                        }catch{
                            print("Unable to save user.")
                            return
                        }
                        
                        print("User succesfully saved.")
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userLoggedIn")
                        
                        self.performSegueWithIdentifier("Login", sender: self)
                    }
                })
            }
        }
    }
    
    // Unwind segue
    @IBAction func unwindToMainLoginSegue(segue: UIStoryboardSegue){
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("View has appeared")
    }
    
    func switchToMain(){
        print("Switching to app.")
        
        let appDelegate = UIApplication.sharedApplication().delegate!
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginNavController = storyBoard.instantiateViewControllerWithIdentifier("LoginNav")
        
        let mainNavController = storyBoard.instantiateViewControllerWithIdentifier("MainNav")
        
        // Now switch controllers
        loginNavController.view.removeFromSuperview()
        appDelegate.window!!.addSubview(mainNavController.view)
    }
    
    
    // Given a result object from FB graph request, saves info into user object
    func saveResult(result: AnyObject){
        let userFirstName: String? = result["first_name"] as? String
        let userLastName: String? = result["last_name"] as? String
        let userEmail: String? = result["email"] as? String
        
        let myUser: PFUser = PFUser.currentUser()!
        
        if(userFirstName != nil){
            myUser.setObject(userFirstName!, forKey: "firstName")
        }
        
        if(userLastName != nil){
            myUser.setObject(userLastName!, forKey: "lastName")
        }
        
        if(userEmail != nil){
            myUser.setObject(userEmail!, forKey: "email")
        }
    }
    
    // Downloads profile picture object
    func saveProfilePicture(userId: String){
        let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
        let profilePictureURL = NSURL(string: userProfile)
        let profilePictureData = NSData(contentsOfURL: profilePictureURL!)
        
        if profilePictureData != nil{
            let profileFileObject = PFFile(data: profilePictureData!)
            PFUser.currentUser()!.setObject(profileFileObject!, forKey: "profilePicture")
        }
    }
}
