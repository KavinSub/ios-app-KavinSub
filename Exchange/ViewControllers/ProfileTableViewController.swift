//
//  ProfileTableViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 12/10/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ProfileTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // The array of all user objects
    var connectedUsers: [PFUser]?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var datesUsersMet: [NSDate]?
    
    override func viewDidLoad(){
        getUsers()
    }
    
    // Gets all users from connections
    func getUsers(){
        let currentUser = PFUser.currentUser()
        
        let connectionQuery = PFQuery(className: "Connection")
        connectionQuery.whereKey("this_user", equalTo: currentUser!)
        connectionQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error != nil{
                print("\(error?.localizedDescription)")
            }
            
            if let objects = objects{
                print("Grabbed connections")
                
                // Collect the dates users met
                for object in objects{
                    let dateObject = object.valueForKey("createdAt")
                    print("")
                }
                
                // get object ids of objects
                var objectIds: [String] = []
                for object in objects{
                    let userObject = object.valueForKey("other_user")!
                    let userObjectId = userObject.objectId!
                    objectIds.append(userObjectId!)
                }

                // now search for users
                let userQuery = PFUser.query()
                userQuery?.whereKey("objectId", containedIn: objectIds)
                userQuery?.orderByDescending("firstName")
                userQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                    if error != nil{
                        print("\(error?.localizedDescription)")
                    }
                    
                    self.connectedUsers = objects as! [PFUser]
                })
            }
        }
    
    }
    
}

extension ProfileTableViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedUsers?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as! ProfileCell
        
        var name: String
        
        if connectedUsers?.count > 0{
            let thisUser = connectedUsers![indexPath.row]
            let firstName = thisUser.valueForKey("firstName")!
            let lastName = thisUser.valueForKey("lastName")!
            name = "\(firstName) \(lastName)"
        }else{
            name = "test"
        }
        
        cell.setName(name)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}