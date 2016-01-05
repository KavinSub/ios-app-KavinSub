//
//  ConnectedUsersViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/4/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ConnectedUsersViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Array of all connected users
    var connectedUsers: [PFUser]?
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad(){
        setupGestures()
        
        downloadUsers()
        
        setupTableView()
    }
    
    func setupGestures(){
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: Selector("closeKeyboards"))
        self.view.addGestureRecognizer(tapScreenGesture)
    }
    
    func closeKeyboards(){
        self.view.endEditing(true)
    }
    
    // Set up table view settings
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIElementProperties.backgroundColor
        tableView.backgroundView = backgroundView
    }
    
    
    // Performs a parse query and fetches all connected users
    func downloadUsers(){
        let user = PFUser.currentUser()!
        
        // i) Get all connection objects
        let connectionQuery = PFQuery(className: "Connection")
        connectionQuery.whereKey("this_user", equalTo: user)
        
        connectionQuery.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) -> Void in
            if error != nil{
                print("\(error?.localizedDescription)")
            }
            if let connections = result{
                print("Found \(connections.count) connection(s).")
                
                // ii) Create an array of object ids of connected users
                var objectIds: [String] = []
                for connection in connections{
                    let userObject = connection.valueForKey("other_user")!
                    objectIds.append(userObject.objectId!!)
                }
                
                // iii) Now we search for users
                let userQuery = PFUser.query()!
                userQuery.whereKey("objectId", containedIn: objectIds)
                userQuery.orderByDescending("firstName")
                
                userQuery.findObjectsInBackgroundWithBlock({ (result: [PFObject]?, error: NSError?) -> Void in
                    if error != nil{
                        print("\(error?.localizedDescription)")
                    }
                    
                    if let users = result as! [PFUser]?{
                        self.connectedUsers = users
                        print("Found \(self.connectedUsers!.count) users.")
                        
                        // Reload data in table view
                        self.tableView.reloadData()
                    }
                })
                
            }else{
                print("Found no connections")
            }
        }
    }
    
}

extension ConnectedUsersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as! ProfileCell
        
        let user = connectedUsers![indexPath.row]
        
        cell.setProfileImage(user.valueForKey("profilePicture") as! UIImage?)
        cell.setName(user.valueForKey("firstName") as! String?, lastName: user.valueForKey("lastName") as! String?)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedUsers?.count ?? 0
    }
    
    // Spacing between sections
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        
        cell.layer.cornerRadius = 30.0
        cell.layer.masksToBounds = true
    }
    
    
}
