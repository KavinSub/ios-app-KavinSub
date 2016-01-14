//
//  ConnectionsViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 1/8/16.
//  Copyright © 2016 Kavin Subramanyam. All rights reserved.
//

import UIKit
import Parse

class ConnectionsViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filteredTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTrailing: NSLayoutConstraint!
    var users: [PFUser]?
    var usersNames: [String]?
    // Array of name strings to filter. Order is as same as users.
    var filteredUsers: [PFUser]?
    
    var selectedUser: PFUser?
    
    let colors: [UIColor] = [UIElementProperties.beigeColor]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsers()
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = 0
        
        filteredTableView.backgroundColor = UIColor.clearColor()
        filteredTableView.tag = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if Exchange.newUserAdded{
            getUsers()
        }
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
        if segue.identifier == "UserProfile"{
            let viewController = segue.destinationViewController as! OtherUserViewController
            viewController.user = selectedUser!
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
                        
                        // For each user, concat their names and put them into an array
                        self.usersNames = []
                        for user in users{
                            let name = (user.valueForKey("firstName") as! String? ?? "") + " " + (user.valueForKey("lastName") as! String? ?? "")
                            self.usersNames!.append(name.uppercaseString)
                        }
                        
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
        
        if tableView.tag == self.tableView.tag{
            
            let user = users![indexPath.section]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("ConnectionsCell") as! ConnectionsCell
            
            cell.setProfileImage(user.valueForKey("profilePicture") as! PFFile?)
            
            cell.setName(user.valueForKey("firstName") as! String? ?? "", lastName: user.valueForKey("lastName") as! String? ?? "")
            
            cell.setJob(user.valueForKey("position") as! String? ?? "", company: user.valueForKey("company") as! String? ?? "")
            
            return cell
        }else if tableView.tag == self.filteredTableView.tag{
            
            if let filteredUsers = filteredUsers{
                
                let user = filteredUsers[indexPath.section]
                
                let cell = tableView.dequeueReusableCellWithIdentifier("FilteredConnectionsCell") as! FilteredConnectionsCell
                
                cell.setProfileImage(user.valueForKey("profilePicture") as! PFFile?)
                
                cell.setName(user.valueForKey("firstName") as! String? ?? "", lastName: user.valueForKey("lastName") as! String? ?? "")
                
                cell.setJob(user.valueForKey("position") as! String? ?? "", company: user.valueForKey("company") as! String? ?? "")
                
                return cell
            }
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView.tag == self.tableView.tag{
            return self.users?.count ?? 0
        }else if tableView.tag == self.filteredTableView.tag{
            return self.filteredUsers?.count ?? 0
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.cornerRadius = 12.0
        cell.layer.masksToBounds = true
        
        cell.contentView.backgroundColor = colors[indexPath.section % colors.count]
        
        if tableView.tag == self.tableView.tag{
            let cCell = cell as! ConnectionsCell
            cCell.nameLabel.adjustsFontSizeToFitWidth = true
            cCell.nameLabel.minimumScaleFactor = 0
        }else if tableView.tag == self.filteredTableView.tag{
            let cCell = cell as! FilteredConnectionsCell
            cCell.nameLabel.adjustsFontSizeToFitWidth = true
            cCell.nameLabel.minimumScaleFactor = 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedUser = users![indexPath.section]
        
        self.performSegueWithIdentifier("UserProfile", sender: self)
    }
}

extension ConnectionsViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        animateSearchBarUsed()
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let usersNames = usersNames{
            let filteredUsersNames = usersNames.filter({ (name: String) -> Bool in
                name.containsString(searchText.uppercaseString)
            })
            
            if filteredUsersNames.count > 0{
                var indexes: [Int] = []
                for name in filteredUsersNames{
                    indexes.append(self.usersNames!.indexOf(name)!)
                }
                filteredUsers = []
                for index in indexes{
                    filteredUsers!.append(users![index])
                }
            }else{
                filteredUsers = []
            }
            
            filteredTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        animateSearchBarDone()
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func animateSearchBarUsed(){
        UIView.animateWithDuration(0.3) { () -> Void in
            self.tableView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * self.view.frame.width, 0.0)
            self.filteredTableView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -1.0 * (self.view.frame.width - (self.view.frame.width - self.filteredTableView.frame.width)/2.0 + 5), 0.0)
        }
    }
    
    func animateSearchBarDone(){
        UIView.animateWithDuration(0.3) { () -> Void in
            self.tableView.transform = CGAffineTransformIdentity
            self.filteredTableView.transform = CGAffineTransformIdentity
        }
    }
}
