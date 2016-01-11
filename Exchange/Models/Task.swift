//
//  Task.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/10/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import Foundation
import Parse
import RealmSwift

// Task object. Will be serialized, saved to NSUserDefaults, then executed upon internet connectivity.
class Task: Object{
    
    // ObjectId of other user
    var objectId: String?
}