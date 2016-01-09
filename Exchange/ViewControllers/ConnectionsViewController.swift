//
//  ConnectionsViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/8/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ConnectionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users: [PFUser]?
    
    var selectedUser: PFUser?
    
    let colors: [UIColor] = [UIElementProperties.blueColor, UIElementProperties.orangeColor, UIElementProperties.yellowColor]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsers()
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func unwindToConnections(segue: UIStoryboardSegue){
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenProfile"{
            let viewController = segue.destinationViewController as! ProfileViewController
            viewController.user = selectedUser!
            viewController.allowsEditMode = false
        }
    }
    
    
    func getUsers(){
        let user = PFUser.currentUser()!
        
        // i) Get all connections
        let connectionQuery = PFQuery(className: "Connection")
        connectionQuery.whereKey("this_user", equalTo: user)
        connectionQuery.selectKeys(["other_user"])
        
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
                        self.users = users
                        print("Found \(self.users!.count) users.")
                        
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

extension ConnectionsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = users![indexPath.section]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ConnectionsCell") as! ConnectionsCell
        
        cell.setProfileImage(user.valueForKey("profilePicture") as! PFFile?)
        
        cell.setName(user.valueForKey("firstName") as! String? ?? "", lastName: user.valueForKey("lastName") as! String? ?? "")
        
        cell.setJob(user.valueForKey("position") as! String? ?? "", company: user.valueForKey("company") as! String? ?? "")
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.cornerRadius = 12.0
        cell.layer.masksToBounds = true
        
        cell.contentView.backgroundColor = colors[indexPath.section % colors.count]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedUser = users![indexPath.section]
        
        self.performSegueWithIdentifier("OpenProfile", sender: self)
    }
}