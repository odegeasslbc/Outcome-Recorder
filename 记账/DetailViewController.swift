//
//  FirstViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var outgoingTable: UITableView!

    //var db:SQLiteDB!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            loginStatus = "yes"
            userName = currentUser!.username!
        }
        println("login: \(loginStatus),username:\(userName)")
        outgoingTable.reloadData()
        self.loadView()
        //PFUser.requestPasswordResetForEmail("fy66@scarletmail.rutgers.edu")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //returning the view
    override func viewWillAppear(animated: Bool) {
        //println(outgoingManager.outgoings)
        outgoingTable.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OutgoingCell", forIndexPath: indexPath) as! OutgoingCell
        
        cell.nameLabel.text = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].name
        cell.descLabel.text = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].desc
        cell.costLabel.text = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].cost

        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            outgoingManager.removeOutgoing(outgoingManager.outgoings.count-1-indexPath.row)
            outgoingTable.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outgoingManager.outgoings.count
    }

}

