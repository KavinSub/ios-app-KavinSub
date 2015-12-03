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
    
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    let bluetoothEventQueue = /*dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/dispatch_queue_create("bluetoothEventQueue", nil)
    var discoveredPeripheral: CBPeripheral?
    
    let exchange = Exchange()
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue){
        
    }
    
    
    override func viewDidLoad(){
        // Set up Exchange Model
        setupAsPeripheral()
        setupAsCentral()
        print("Setup completed")
    }
    
    // By default, device is peripheral manager
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // When called, device becomes a central
    func setupAsCentral(){
        //initialize central manager
        centralManager = CBCentralManager(delegate: self, queue: bluetoothEventQueue, options: nil)
        print("Setup as central")
    }
    
    
    // By default, device is to be treated as a peripheral
    func setupAsPeripheral(){
        // Initialize peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: bluetoothEventQueue, options: nil)
        print("Setup as peripheral")
    }
    
    // If bluetooth isn't on, this alert controller will be presented
    func presentBluetoothNotOn(){
        let alertController = UIAlertController(title: nil, message: "Turn on Bluetooth, you scrub.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // **************************** Ignore for now ***********************
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
        
    }
    //********************************************************************
    
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
    
    func createConnection(otherUser: String?){
        if let otherUser = otherUser{
            // Query User class for instance of otherUser
            var userQuery = PFQuery(className: "User")
            userQuery.whereKey("username", equalTo: otherUser)
            
            do{
                // Find user
                let userObjects = try userQuery.findObjects()
                let user = userObjects.first
                
                if let user = user{
                    // Check if connection object already exists
                    let connectionQuery = PFQuery(className: "Connection")
                    connectionQuery.whereKey("this_user", equalTo: user)
                    
                    do{
                        let connectionObjects = try connectionQuery.findObjects()
                        // If no connection exists
                        if connectionObjects.count == 0{
                            // Create new connection object
                            let connectionObject = PFObject(className: "Connection")
                            connectionObject.setValue(user, forKey: "other_user")
                            connectionObject.setValue(PFUser.currentUser(), forKey: "this_user")
                            connectionObject.saveInBackgroundWithBlock{ (result: Bool, error: NSError?) -> Void in
                               
                            }
                        }else{
                            print("Connection already exists")
                        }
                    }catch{
                        print("Unable to perform connection query")
                    }
                }else{
                    print("Unable to find other user")
                }
            }catch{
                print("Unable to perform user query")
            }
        }
        
    }
    
}

extension ExchangeViewController: CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate{
    //*******************************Peripheral Manager********************************
    // Called when peripheral publishes service
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if((error) != nil){
            print("Error adding service: \(error?.localizedDescription)")
        }else{
            print("Service added")
        }
    }
    
    // Called when peripheral begins to advertise services
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if(error != nil){
            print("Error while advertising: \(error?.localizedDescription)")
        }else{
            print("Currently Advertising")
        }
    }
    
    
    // Called when peripheral receives request from remote central
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("Request received")
        // If requested UUID is equal to our exchange characteristic UUID
        if(request.characteristic.UUID.isEqual(exchange.exchangeCharacteristic.UUID)){
            let offset = request.offset
            let valLength = exchange.exchangeCharacteristic.value!.length
            if(offset > valLength){
                peripheralManager!.respondToRequest(request, withResult: CBATTError.InvalidOffset)
                return
            }else{
                request.value = exchange.exchangeCharacteristic.value?.subdataWithRange(NSMakeRange(offset, valLength - offset))
                peripheralManager?.respondToRequest(request, withResult: CBATTError.Success)
                return
            }
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        // Do nothing
        if (peripheral.state ==  .PoweredOn) {
            // Add exchange service from exchange model to peripheral device
            peripheralManager!.addService(exchange.exchangeService)
            // Begin advertising services
            peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [exchange.exchangeService.UUID]])
        }else{
            print("Bluetooth not on")
            presentBluetoothNotOn()
        }
    }
    
    //*******************************Central Manager********************************
    // Called when a peripheral is discovered by the central manager
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        // Log discovered peripheral
        print("Central discovered \(peripheral.name)")
        // Stop scanning
        centralManager!.stopScan()
        print("Scanning stopped")
        // Connect to discovered peripheral
        self.discoveredPeripheral = peripheral
        centralManager!.connectPeripheral(self.discoveredPeripheral!, options: nil)
    }
    
    // Called when connection to peripheral was made
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connection to peripheral established")
        peripheral.delegate = self
        // Discover services
        peripheral.discoverServices([exchange.exchangeService.UUID])
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if(central.state == CBCentralManagerState.PoweredOn){
            // Begin scanning peripherals with services
            centralManager?.scanForPeripheralsWithServices([exchange.exchangeService.UUID], options: nil)
            print("Now scanning for devices")
        }else{
            print("Bluetooth not on")
            presentBluetoothNotOn()
        }
    }
    
    // Called when the Central failed to establish connection with peripheral
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to peripheral")
    }
    
    //*******************************Peripheral********************************
    // Called when services of peripheral are discovered by central
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if peripheral.state == CBPeripheralState.Connected{
            for service in peripheral.services!{
                print("Discovered service \(service)")
            }
            // Discover characteristics
            peripheral.discoverCharacteristics([exchange.exchangeCharacteristic.UUID], forService: peripheral.services!.first!)
        }else{
            print("Unable to discover characteristics")
        }
    }
    
    // Called when characteristics of service are discovered
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if peripheral.state == CBPeripheralState.Connected{
            for characteristic in service.characteristics!{
                print("Discovered characteristics \(characteristic)")
            }
            peripheral.readValueForCharacteristic(service.characteristics!.first!)
        }else{
            print("Unable to read characteristic")
        }
    }
    
    
    // Called when attempt is made to read characteristic of service
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if peripheral.state == CBPeripheralState.Connected{
            let data: NSData = characteristic.value!
            // We may now parse the data
            let userString = NSString(data: data, encoding: NSUTF8StringEncoding)
            print(userString)
            // TODO : Actually add connection object
            createConnection(String(userString))
                
        }else{
            print("Unable to read data")
        }
    }
    
    
}
