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
    
    static var allowExchange: Bool = NSUserDefaults.standardUserDefaults().valueForKey("allowExchange") as! Bool? ?? true
    
    let exchange = Exchange()
    var bluetoothHandler: Bluetooth?
    
    let initialValue: CGFloat = 120
    let shrinkFactor: CGFloat = 0.75
    
    // Status view button
    var statusButton: UIButton?

    var rippleTimer: NSTimer?
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue){
    }
    
    func createRipple(){
        // Draw blue circle radiating from center
        
        let frame = CGRectMake(self.view.center.x - initialValue * shrinkFactor/2.0, self.view.center.y - initialValue * shrinkFactor/2.0, initialValue * shrinkFactor, initialValue * shrinkFactor)
        let blueCircle = UIView(frame: frame)
        blueCircle.backgroundColor = UIElementProperties.backgroundColor
        
        blueCircle.layer.cornerRadius = blueCircle.frame.width/2.0
        blueCircle.layer.masksToBounds = true
        
        self.view.insertSubview(blueCircle, belowSubview: statusButton!)
        
        let circleAnimation = { () -> Void in
            blueCircle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 4.0, 4.0)
            blueCircle.backgroundColor = UIElementProperties.textColor
        }
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: circleAnimation) { (succeeded: Bool) -> Void in
            blueCircle.removeFromSuperview()
        }
    }
    
    func statusTouchDown(){
        // Shrink center button
        UIView.animateWithDuration(0.2) { () -> Void in
            self.statusButton!.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.shrinkFactor, self.shrinkFactor)
        }
        
        createRipple()
        
    }
    
    func statusTouchUpInside(){
        UIView.animateWithDuration(0.2) { () -> Void in
            self.statusButton!.transform = CGAffineTransformIdentity
        }
    }
    
    func statusTouchUpOutside(){
        UIView.animateWithDuration(0.2) { () -> Void in
            self.statusButton!.transform = CGAffineTransformIdentity
        }
    }
    
    @IBAction func goToProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("DisplayCurrentUser", sender: self)
    }
        
    override func viewDidLoad(){
        
        setupStatusView()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIElementProperties.textColor
        
        bluetoothHandler = Bluetooth(viewController: self)
        
        if ExchangeViewController.allowExchange{
            turnOnBluetooth()
            if rippleTimer == nil{
                setupTimers()
            }
        }else{
            turnOffBluetooth()
            if let rippleTimer = rippleTimer{
                rippleTimer.invalidate()
            }
        }
    }
    

    override func viewDidAppear(animated: Bool) {
        statusButton?.backgroundColor = UIElementProperties.textColor
        
        if ExchangeViewController.allowExchange{
            turnOnBluetooth()
            if rippleTimer == nil{
                setupTimers()
            }
        }else{
            turnOffBluetooth()
            if let rippleTimer = rippleTimer{
                rippleTimer.invalidate()
            }
        }
        
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        turnOffBluetooth()
        
        super.viewDidDisappear(animated)
    }
    
    func connectionCreated(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        statusButton?.backgroundColor = UIElementProperties.connectionStatus
    }
    
    func setupStatusView(){
        statusButton = UIButton(frame: CGRectMake(0, 0, 120, 120))
        statusButton!.center = self.view.center
        
        // Add display properties
        statusButton!.backgroundColor = UIElementProperties.textColor
        statusButton!.layer.cornerRadius = statusButton!.frame.width/2.0
        statusButton!.layer.masksToBounds = true
        statusButton!.layer.borderColor = UIElementProperties.backgroundColor.CGColor
        statusButton!.layer.borderWidth = 3.0
        
        // Add actions
        statusButton!.addTarget(self, action: Selector("statusTouchDown"), forControlEvents: UIControlEvents.TouchDown)
        statusButton!.addTarget(self, action: Selector("statusTouchUpInside"), forControlEvents: UIControlEvents.TouchUpInside)
        statusButton!.addTarget(self, action: Selector("statusTouchUpOutside"), forControlEvents: UIControlEvents.TouchUpOutside)
        
        self.view.addSubview(statusButton!)
    }
    
    func setupTimers(){
        rippleTimer = NSTimer(timeInterval: 1.5, target: self, selector: Selector("createRipple"), userInfo: nil, repeats: true)
        let runner = NSRunLoop.currentRunLoop()
        runner.addTimer(rippleTimer!, forMode: NSDefaultRunLoopMode)
    }
    
    func turnOnBluetooth(){
        bluetoothHandler?.setupAsCentral()
        bluetoothHandler?.setupAsPeripheral()
    }
    
    func turnOffBluetooth(){
        bluetoothHandler?.stopScan()
        bluetoothHandler?.stopAdvertisting()
    }
    
}
