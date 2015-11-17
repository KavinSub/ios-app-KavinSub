//
//  LoginViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/16/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
    }
}
