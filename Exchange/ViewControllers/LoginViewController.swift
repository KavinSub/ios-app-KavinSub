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
        
        // Attempt to login asking for permissions
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"]){
            (user: PFUser?, error: NSError?) in
            
            // Present an error if error is present
            if(error != nil){
                var myAlert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
            
            print(user)
            //print("Current user token = \(FBSDKAccessToken.currentAccessToken().tokenString)")
            //print("Current user ID = \(FBSDKAccessToken.currentAccessToken().userID)")
            
            if(FBSDKAccessToken.currentAccessToken() != nil){
                
            }
        }
        // Get appropriate read permissions
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        
        userDetails.startWithCompletionHandler { (connection, result, error: NSError?) -> Void in
            if(error != nil){
                print(error?.localizedDescription)
                return
            }
            
            if(result != nil){
                let userId:String = result["id"] as! String
                let userFirstName: String? = result["first_name"] as? String
                let userLastName: String? = result["last_name"] as? String
                let userEmail: String? = result["email"] as? String
                
                //print("\(userEmail)")
                
                let myUser: PFUser = PFUser.currentUser()!
                
                if(userFirstName != nil){
                    myUser.setObject(userFirstName!, forKey: "firstName")
                    //print("\(userFirstName)")
                }
                
                if(userLastName != nil){
                    myUser.setObject(userLastName!, forKey: "lastName")
                    //print("\(userLastName)")
                }
                
                if(userEmail != nil){
                    myUser.setObject(userEmail!, forKey: "email")
                    //print("\(userEmail)")
                }
                
                // Get user profile data, save new user
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    let profilePictureURL = NSURL(string: userProfile)
                    let profilePictureData = NSData(contentsOfURL: profilePictureURL!)
                    
                    if profilePictureData != nil{
                        let profileFileObject = PFFile(data: profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "profilePicture")
                    }
                    
                    myUser.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                        if(success){
                            print("User details are now updated")
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userLoggedIn")
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()

        // Set this controller to be the Google UI Delegate
        /*GIDSignIn.sharedInstance().uiDelegate = self
        let googleLoginButton = GIDSignInButton()
        googleLoginButton.center = CGPoint(x: 200, y: 200)
        self.view.addSubview(googleLoginButton)*/
        
        bypassLogin()
    }
    
    override func viewDidAppear(animated: Bool) {
        bypassLogin()
    }
    
    func bypassLogin(){
        // If the user has been authenticated, bypass the login screen
        let isAuthenticated = NSUserDefaults.standardUserDefaults().boolForKey("userLoggedIn")
        
        if isAuthenticated{
            let toController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ExchangeViewController")
            self.presentViewController(toController, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
}
