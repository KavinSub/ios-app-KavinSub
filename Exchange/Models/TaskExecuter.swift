//
//  TaskExecuter.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/10/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import Foundation
import Parse
import RealmSwift

enum ConnectionStatus{
    case SavedNow
    case SavedLater
}

class TaskExecuter: NSObject{
    
    static func perform(task: Task, status: ConnectionStatus){
        print("Task is to be executed.")
        
        let objectId = task.valueForKey("objectId") as! String
        
        let thisUser = PFUser.currentUser()!
        let otherUser = PFUser(withoutDataWithObjectId: objectId)
        
        let connectionObject = PFObject(className: "Connection")
        connectionObject.setValue(thisUser, forKey: "this_user")
        connectionObject.setValue(otherUser, forKey: "other_user")
        
        // i) Check that connection doesn't exist
        let connectionQuery = PFQuery(className: "Connection")
        connectionQuery.whereKey("this_user", equalTo: thisUser)
        connectionQuery.whereKey("other_user", equalTo: otherUser)
        
        connectionQuery.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) -> Void in
            if error != nil{
                print(error?.localizedDescription)
            }
            
            if status == ConnectionStatus.SavedLater{
                // Now remove the task from the list of tasks
                let realm = try! Realm()
                realm.delete(task)
            }
            
            // ii) We can proceed. Save new connection object.
            if result == nil{
                connectionObject.saveEventually()
            }else{
                print("Connection already exists.")
            }
        }
    }
}