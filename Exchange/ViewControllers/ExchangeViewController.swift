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
    
    @IBAction func becomeCentral(sender: AnyObject) {
        setupAsCentral()
        print("Switch made to central")
    }

    
    override func viewDidLoad(){
        // Set up Exchange Model
        Exchange.addCharacteristics()
        setupAsPeripheral()
        
    }
    
    // By default, device is peripheral manager
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // When called, device becomes a central
    func setupAsCentral(){
        // Deinitalize peripheral manager, initialize central manager
        peripheralManager = nil
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    
    // By default, device is to be treated as a peripheral
    func setupAsPeripheral(){
        // Initialize peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        print("Setup as peripheral")
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
        if(request.characteristic.UUID.isEqual(Exchange.exchangeCharacteristic.UUID)){
            let offset = request.offset
            let valLength = Exchange.exchangeCharacteristic.value!.length
            if(offset > valLength){
                peripheralManager!.respondToRequest(request, withResult: CBATTError.InvalidOffset)
                return
            }else{
                request.value = Exchange.exchangeCharacteristic.value?.subdataWithRange(NSMakeRange(offset, valLength - offset))
                peripheralManager?.respondToRequest(request, withResult: CBATTError.Success)
                return
            }
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        // Do nothing
        if (peripheral.state ==  .PoweredOn) {
            // Add exchange service from exchange model to peripheral device
            peripheralManager!.addService(Exchange.exchangeService)
            // Begin advertising services
            peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [Exchange.exchangeService.UUID]])
        }else{
            print("Bluetooth not on")
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
        centralManager!.connectPeripheral(peripheral, options: nil)
    }
    
    // Called when connection to peripheral was made
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connection to peripheral established")
        peripheral.delegate = self
        // Discover services
        peripheral.discoverServices([Exchange.exchangeService.UUID])
        
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if(central.state == CBCentralManagerState.PoweredOn){
            // Begin scanning peripherals with services
            centralManager?.scanForPeripheralsWithServices([Exchange.exchangeService.UUID], options: nil)
            print("Now scanning for devices")
        }else{
            print("Bluetooth not on")
        }
    }
    
    //*******************************Peripheral********************************
    // Called when services of peripheral are discovered by central
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services!{
            print("Discovered service \(service)")
        }
        // Discover characteristics
        peripheral.discoverCharacteristics([Exchange.exchangeCharacteristic.UUID], forService: Exchange.exchangeService)
    }
    
    // Called when characteristics of service are discovered
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristic in service.characteristics!{
            print("Discovered characteristics \(characteristic)")
        }
        peripheral.readValueForCharacteristic(Exchange.exchangeCharacteristic)
    }
    
    
    // Called when attempt is made to read characteristic of service
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        let data: NSData = characteristic.value!
        // We may now parse the data
        let userString = NSString(data: data, encoding: NSUTF8StringEncoding)
        print(userString)
    }
}
