//
//  ExchangeViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/19/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import CoreBluetooth
import Parse
import AudioToolbox

class ExchangeViewController: UIViewController {
    
    let exchange = Exchange()
    var bluetoothHandler: Bluetooth?
    
    @IBOutlet weak var statusView: UIView!
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue){
    }
    
    
    @IBAction func goToProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("DisplayCurrentUser", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DisplayCurrentUser"{
            let viewController = segue.destinationViewController as! UserViewController
            viewController.user = PFUser.currentUser()
            viewController.allowsEditMode = true
        }
    }
    
    override func viewDidLoad(){
        
        statusView.backgroundColor = UIElementProperties.textColor
        
        setupStatusView()
        
        bluetoothHandler = Bluetooth(viewController: self)
        
        bluetoothHandler?.setupAsCentral()
        bluetoothHandler?.setupAsPeripheral()
    }
    

    override func viewDidAppear(animated: Bool) {
        statusView.backgroundColor = UIElementProperties.textColor
        
        bluetoothHandler?.setupAsCentral()
        bluetoothHandler?.setupAsPeripheral()
        
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        bluetoothHandler?.stopScan()
        bluetoothHandler?.stopAdvertisting()
        
        super.viewDidDisappear(animated)
    }
    
    func connectionCreated(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        statusView.backgroundColor = UIElementProperties.connectionStatus
    }
    
    func setupStatusView(){
        statusView.layer.cornerRadius = statusView.layer.frame.width/2.0
        statusView.layer.masksToBounds = true
    }
    
    
}
