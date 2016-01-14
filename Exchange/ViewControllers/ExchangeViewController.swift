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
import RealmSwift


class ExchangeViewController: UIViewController {
    
    static var allowExchange: Bool = NSUserDefaults.standardUserDefaults().valueForKey("allowExchange") as! Bool? ?? true
    
    let exchange = Exchange()
    var bluetoothHandler: Bluetooth?
    
    let initialValue: CGFloat = 120
    let shrinkFactor: CGFloat = 0.75
    
    var hasLoaded = false
    var hasTurnedOnFirstTime = false
    
    // Status view button
    var statusButton: UIButton?
    
    var customRipple = false
    
    var rippleTimer: NSTimer?
    
    var dots = 0
    
    @IBOutlet weak var scanningLabel: UILabel!
    let baseText = "Scanning for devices"
    
    func animateScanningLabel(){
        let array = Array(count: dots, repeatedValue: ".")
        scanningLabel.text = baseText + array.joinWithSeparator("")
        dots = (dots + 1) % 4
    }
    
    func setScanningLabelTimer(){
        let scanningLabelTimer = NSTimer(timeInterval: 0.4, target: self, selector: Selector("animateScanningLabel"), userInfo: nil, repeats: true)
        let runner = NSRunLoop.currentRunLoop()
        runner.addTimer(scanningLabelTimer, forMode: NSDefaultRunLoopMode)
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue){
    }
    
    func createRipple(){
        if !customRipple{
            // Draw blue circle radiating from center
            
            let frame = CGRectMake(self.view.center.x - initialValue * shrinkFactor/2.0, self.view.center.y - initialValue * shrinkFactor/2.0, initialValue * shrinkFactor, initialValue * shrinkFactor)
            let blueCircle = UIView(frame: frame)
            blueCircle.backgroundColor = UIElementProperties.backgroundColor
            
            blueCircle.layer.cornerRadius = blueCircle.frame.width/2.0
            blueCircle.layer.masksToBounds = true
            
            self.view.insertSubview(blueCircle, belowSubview: statusButton!)
            
            let circleAnimation = { () -> Void in
                blueCircle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 4.0, 4.0)
                blueCircle.backgroundColor = UIColor.whiteColor()
            }
            
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: circleAnimation) { (succeeded: Bool) -> Void in
                blueCircle.removeFromSuperview()
            }
        }
    }
    
    func createRippleWithColor(color: UIColor){
        // Draw blue circle radiating from center
        customRipple = true
        let frame = CGRectMake(self.view.center.x - initialValue * shrinkFactor/2.0, self.view.center.y - initialValue * shrinkFactor/2.0, initialValue * shrinkFactor, initialValue * shrinkFactor)
        let circle = UIView(frame: frame)
        circle.backgroundColor = color
        
        circle.layer.cornerRadius = circle.frame.width/2.0
        circle.layer.masksToBounds = true
        
        self.view.insertSubview(circle, belowSubview: statusButton!)
        
        let circleAnimation = { () -> Void in
            circle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 4.0, 4.0)
            circle.backgroundColor = UIColor.whiteColor()
        }
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: circleAnimation) { (succeeded: Bool) -> Void in
            self.customRipple = false
            circle.removeFromSuperview()
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
        scanningLabel.text = baseText
        setScanningLabelTimer()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIElementProperties.textColor
        
        bluetoothHandler = Bluetooth(viewController: self)
        
        if ExchangeViewController.allowExchange{
            if !hasTurnedOnFirstTime{
                turnOnBluetoothFirstTime()
                hasTurnedOnFirstTime = true
            }
            if rippleTimer == nil{
                setupTimers()
            }
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                self.scanningLabel.alpha = 1.0
            })
        }else{
            turnOffBluetooth()
            if let rippleTimer = rippleTimer{
                rippleTimer.invalidate()
            }
            rippleTimer = nil
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                self.scanningLabel.alpha = 0.0
            })
        }
    }
    

    override func viewDidAppear(animated: Bool) {
        statusButton?.backgroundColor = UIElementProperties.textColor
        if hasLoaded{
            if ExchangeViewController.allowExchange{
                if !hasTurnedOnFirstTime{
                    turnOnBluetoothFirstTime()
                    hasTurnedOnFirstTime = true
                }else{
                    turnOnBluetooth()
                }
                if rippleTimer == nil{
                    setupTimers()
                }
                UIView.animateWithDuration(0.7, animations: { () -> Void in
                    self.scanningLabel.alpha = 1.0
                })
            }else{
                turnOffBluetooth()
                if let rippleTimer = rippleTimer{
                    rippleTimer.invalidate()
                }
                rippleTimer = nil
                UIView.animateWithDuration(0.7, animations: { () -> Void in
                    self.scanningLabel.alpha = 0.0
                })
            }
        }
        
        hasLoaded = true
        
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        turnOffBluetooth()
        
        super.viewDidDisappear(animated)
    }
    
    func connectionCreated(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        //statusButton?.backgroundColor = UIElementProperties.connectionStatus
        let circle = UIView(frame: CGRectMake(0, 0, 1, 1))
        circle.backgroundColor = UIColor(red: 255.0/255.0, green: 192.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        circle.center.x = statusButton!.frame.width/2.0
        circle.center.y = statusButton!.frame.height/2.0
        circle.userInteractionEnabled = false
        
        self.statusButton!.addSubview(circle)
        let radius = statusButton!.frame.width/2.0
        let animation = { () -> Void in
            circle.transform = CGAffineTransformScale(CGAffineTransformIdentity, radius * 2.0, radius * 2.0)
        }
        
        UIView.animateWithDuration(0.5, animations: animation) { (success: Bool) -> Void in
            let whiteCircle = UIView(frame: CGRectMake(0, 0, 0.1, 0.1))
            whiteCircle.backgroundColor = UIColor.clearColor()
            whiteCircle.center.x = self.statusButton!.frame.width/2.0
            whiteCircle.center.y = self.statusButton!.frame.height/2.0
            whiteCircle.userInteractionEnabled = false
            
            self.statusButton!.insertSubview(whiteCircle, aboveSubview: circle)
            
            let animation = {() -> Void in
                whiteCircle.transform = CGAffineTransformScale(CGAffineTransformIdentity, radius * 2.0 * 10, radius * 2.0 * 10)
            }
            
            UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animation, completion: { (success: Bool) -> Void in
                circle.removeFromSuperview()
                whiteCircle.removeFromSuperview()
                
                let orangeColor = UIColor(red: 255.0/255.0, green: 192.0/255.0, blue: 14.0/255.0, alpha: 1.0)
                self.createRippleWithColor(orangeColor)
                
            })
        }
        

        
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
    
    func turnOnBluetoothFirstTime(){
        bluetoothHandler?.setupAsCentral()
        bluetoothHandler?.setupAsPeripheral()
    }
    
    func turnOnBluetooth(){
        //bluetoothHandler?.setupAsCentral()
        //bluetoothHandler?.setupAsPeripheral()
        bluetoothHandler?.scan()
        bluetoothHandler?.advertise()
    }
    
    func turnOffBluetooth(){
        bluetoothHandler?.stopScan()
        bluetoothHandler?.stopAdvertisting()
    }
    
}
