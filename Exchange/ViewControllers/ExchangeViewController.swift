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

class ExchangeViewController: UIViewController {
    
    let exchange = Exchange()
    var bluetoothHandler: Bluetooth?
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue){
        
    }
    
    
    override func viewDidLoad(){
        bluetoothHandler = Bluetooth(viewController: self)
        
        bluetoothHandler?.setupAsCentral()
        bluetoothHandler?.setupAsPeripheral()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        bluetoothHandler?.stopScan()
        bluetoothHandler?.stopAdvertisting()
        
        super.viewDidDisappear(animated)
    }
    
}
