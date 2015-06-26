//
//  FirstViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class OutgoingListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var index:NSIndexPath?
    
    var detailViewController: OutgoingDetailViewController? = nil
    
    @IBOutlet var outgoingTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            loginStatus = "yes"
            userName = currentUser!.username!
        }
        println("login: \(loginStatus),username:\(userName)")
        */
        outgoingTable.reloadData()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? OutgoingDetailViewController
        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "show detail"){
            //let indexPath = self.outgoingTable.indexPathForCell(sender as! OutgoingCell)
            let indexPath = self.outgoingTable.indexPathForSelectedRow()
            
            let cell = outgoingTable.cellForRowAtIndexPath(indexPath!) as! OutgoingCell
            //println(cell.nameLabel.text)

            let dvc:OutgoingDetailViewController! = segue.destinationViewController as! OutgoingDetailViewController
            //let dvc = segue.destinationViewController
            //println(userName)
            dvc.detailItem = outgoing(id: cell.id!, name: cell.nameLabel.text!, desc: cell.descLabel.text!, cost: cell.costLabel.text!,user: userName)
            //dvc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            //dvc.navigationItem.leftItemsSupplementBackButton = true

        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OutgoingCell", forIndexPath: indexPath) as! OutgoingCell
        cell.id = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].id
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

