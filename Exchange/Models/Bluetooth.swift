//
//  Bluetooth.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/8/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class Bluetooth: NSObject{
    // Instance of Exchange
    let exchange = Exchange()
    
    // Global variables for bluetooth
    var centralManager: CBCentralManager?
    var discoveredPeripheral: CBPeripheral?
    
    var peripheralManager: CBPeripheralManager?
    
    var exchangedData: NSData?
    
    // An array of peripherals we have interacted with so far
    var peripheralsInteracted: [CBPeripheral] = []
    
    // Event queue for all Bluetooth events
    let bluetoothEventQueue = dispatch_queue_create("bluetoothEventQueue", DISPATCH_QUEUE_CONCURRENT)
    
    // Reference to the enclosing view controller
    var viewController: UIViewController
    
    
    init(viewController: UIViewController){
        self.viewController = viewController
        
        super.init()
    }
    
    // Sets up device as a central manager
    func setupAsCentral(){
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        print("Setup as central")
    }
    
    // Sets up the device as a peripheral manager
    func setupAsPeripheral(){
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        print("Setup as peripheral")
    }
    
    // Displays an alert telling user to turn on bluetooth
    func presentBluetoothNotOn(){
        let alertController = UIAlertController(title: nil, message: "Turn on Bluetooth, you scrub.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

// Extension responsible for handling Central Manager tasks
extension Bluetooth: CBCentralManagerDelegate{
    // Starts scanning
    func scan(){
        self.centralManager!.scanForPeripheralsWithServices([exchange.exchangeService.UUID], options: nil)
        print("Central has begun scanning for devices")
    }
    
    // Called when central manager changes state
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if(central.state != CBCentralManagerState.PoweredOn){
            print("Central Manager not on")
            presentBluetoothNotOn()
            return
        }else{
            print("Central Manager is on")
            self.scan()
        }
    }
    
    // Called when the central manager discovers a peripheral
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // If we have not interacted with this peripheral yet
        if(!peripheralsInteracted.contains(peripheral)){
            peripheralsInteracted.append(peripheral)
            
            // Save local copy
            self.discoveredPeripheral = peripheral
            
            // Connect
            print("Connecting to \(peripheral.name)")
            self.centralManager?.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Successful connection to peripheral made")
        
        // Stop scanning for other devices
        self.centralManager?.stopScan()
        print("Scanning stopped")
        
        // Clear data
        self.exchangedData = nil
        
        // Set delegate of peripheral
        peripheral.delegate = self
        
        // Begin searching for relevant services
        peripheral.discoverServices([exchange.exchangeService.UUID])
    }

    // Called when the central fails to connect to a peripheral
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to \(peripheral). Error: \(error?.localizedDescription)")
        
        // Remove the peripheral from the list of interacted peripherals
        let index = peripheralsInteracted.indexOf(peripheral)
        if let index = index{
            peripheralsInteracted.removeAtIndex(Int(index.value))
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // Clean up the peripheral we are interacting with
        print("Disconnected from peripheral")
        discoveredPeripheral = nil
        
        // Begin scanning again
        self.scan()
    }
    
}

// Extension responsible for handling Peripheral Manager tasks
extension Bluetooth: CBPeripheralManagerDelegate{
    // Called when peripheral manager changes state
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if(peripheral.state != CBPeripheralManagerState.PoweredOn){
            print("Peripheral Manager not on")
            return
        }else{
            print("Peripheral Manager is on")
            peripheralManager!.addService(exchange.exchangeService)
            peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [exchange.exchangeService.UUID]])
            print("Peripheral has begun advertising services")
        }
    }
    
    
}

extension Bluetooth: CBPeripheralDelegate{
    
}