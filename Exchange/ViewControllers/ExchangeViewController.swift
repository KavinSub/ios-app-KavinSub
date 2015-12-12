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
    
    @IBOutlet weak var statusView: UIView!
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad(){
        
        statusView.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 255)
        
        bluetoothHandler = Bluetooth(viewController: self)
        
        bluetoothHandler?.setupAsCentral()
        bluetoothHandler?.setupAsPeripheral()
    }
    

    
    
    override func viewDidAppear(animated: Bool) {
        statusView.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 255)
        
        bluetoothHandler?.setupAsCentral()
        bluetoothHandler?.setupAsPeripheral()
        
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        bluetoothHandler?.stopScan()
        bluetoothHandler?.stopAdvertisting()
        
        super.viewDidDisappear(animated)
    }
    
}
