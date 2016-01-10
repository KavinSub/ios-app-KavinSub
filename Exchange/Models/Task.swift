//
//  Task.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/10/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import Foundation
import Parse


// Task object. Will be serialized, saved to NSUserDefaults, then executed upon internet connectivity.
class Task: NSObject{
    
    // ObjectId of other user
    var objectId: String
    
    init(userId: String){
        objectId = userId
    }
    
    
    
    func perform(){
        print("Task is to be executed.")
        
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
            
            // ii) We can proceed. Save new connection object.
            if result == nil{
                connectionObject.saveEventually()
            }else{
                print("Connection already exists.")
            }
        }
    }
    
    // Made for the purposes of testing
    func testAction(){
        print("Task contains \(self.objectId). Has been tested.")
    }
    
    // Executes all queued tasks
    static func executeTasks(){
        print("Executing tasks/")
    }
    
}