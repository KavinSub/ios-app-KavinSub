//
//  ExchangeViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/19/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import CoreBluetooth

class ExchangeViewController: UIViewController {
    
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    
    @IBAction func getOrientation(sender: AnyObject) {
        
    }
    
    override func viewDidLoad(){
        // Set up Exchange Model
        Exchange.addCharacteristics()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // Sets device to be central or peripheral device based on orientation
    /*
    If device is facing up, device becomes a central manager
    If device is facing down, device becomes a peripheral manager
    */
    
    func setupDevices(){
        // Turn on accelorometer
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        // Begin receiving events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("orientationChanged"), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func orientationChanged(){
        print("Orientation Changed")
        let orientation = UIDevice.currentDevice().orientation
        
        if orientation == UIDeviceOrientation.FaceUp{
            centralManager = CBCentralManager.init(delegate: self, queue: nil, options: nil)
            peripheralManager = nil
        }else if orientation == UIDeviceOrientation.FaceDown{
            centralManager = nil
            peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil, options: nil)
        }else{
            centralManager = nil
            peripheralManager = nil
        }
    }
    
    // Helper function, prints orientation based on current value
    func printOrientation(orientation: Int){
        switch orientation{
        case 5:
            print("Face Up")
        case 6:
            print("Face Down")
        case 3:
            print("Landscape Left")
        case 4:
            print("Landscape Right")
        case 1:
            print("Portrait")
        case 2:
            print("Portrait Upside Down")
        default:
            print("Unknown orientation")
        }
    }
    
}

extension ExchangeViewController: CBCentralManagerDelegate, CBPeripheralManagerDelegate{
    
}
