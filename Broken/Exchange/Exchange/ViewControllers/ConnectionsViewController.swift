//
//  ConnectionsViewController.swift
//  Exchange
//
//  Created by Kavin Subramanyam on 11/16/15.
//  Copyright © 2015 Kavin Subramanyam. All rights reserved.
//

import UIKit

class ConnectionsViewController: UIViewController {
    @IBAction func unwindToConnectionsController(segue: UIStoryboardSegue){
        
    }
}

extension ConnectionsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConnectionsCell")!
        cell.textLabel?.text = "Test Cell"
        return cell
    }
}