//
//  Exchange.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/23/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import Foundation
import CoreBluetooth
import Parse

class Exchange{
    // Custom UUID's
    let exchangeCharacteristicUUID = CBUUID(string: "C7E4333D-E760-4769-975A-C5FB28ECCECA")
    let exchangeServiceUUID = CBUUID(string: "7C950867-15B1-47B3-B6B6-88BDF9B848E7")
    
    // Exchange characteristic contains PFUser ID
    let exchangeCharacteristic: CBMutableCharacteristic
    // Exchange Service
    let exchangeService: CBMutableService
    
    init() {
        let userData = PFUser.currentUser()?.username!.dataUsingEncoding(NSUTF8StringEncoding)
        exchangeCharacteristic = CBMutableCharacteristic(type: exchangeCharacteristicUUID, properties: CBCharacteristicProperties.Read, value: userData, permissions: CBAttributePermissions.Readable)
        exchangeService = CBMutableService(type: exchangeServiceUUID, primary: true)
        exchangeService.characteristics = [exchangeCharacteristic]
    }
    
}
