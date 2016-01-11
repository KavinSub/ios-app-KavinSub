//
//  NetworkHelper.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/10/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import Foundation
import RealmSwift

// Class to help with network connectivity issues
class NetworkHelper: NSObject{
    
    func reachabilityChanged(note: NSNotification){
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable(){
            // Begin executing tasks
            let realm = try! Realm()
            var tasks = realm.objects(Task)
            while reachability.isReachable() && tasks.count > 0{
                tasks.forEach({ (task: (Task)) -> () in
                    TaskExecuter.perform(task, status: ConnectionStatus.SavedLater)
                })
            }
        }else{
            print("Not Reachable")
        }
        
    }
}