//
//  NetworkHelper.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/10/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import Foundation

// Class to help with network connectivity issues
class NetworkHelper: NSObject{
    
    func reachabilityChanged(note: NSNotification){
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable(){
            // Begin executing tasks
        }else{
            print("Not Reachable")
        }
        
    }
}