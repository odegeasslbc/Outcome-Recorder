//
//  FirstViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class OutgoingListViewController: CBViewController,UITableViewDelegate,UITableViewDataSource{
    
    var index:NSIndexPath?
    
    var detailViewController: OutgoingDetailViewController? = nil
    
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var outgoingTable: UITableView!
    
    func reloadTable(){
        outgoingManager.syncWithCloud()
        println(outgoingManager.outgoings.count)
        self.view.alpha = 0.9
        UIView.animateWithDuration(0.8, animations: {self.view.alpha=0.1}, completion: { finished in
            self.outgoingTable.reloadData()
            self.view.alpha=1
        })
    }
    
    //****** 小圆球执行的事件将在这里进行 ******
    override func shareCircleView(aShareCircleView: CFShareCircleView!, didSelectSharer sharer: CFSharer!) {
        panView.center = panviewPosition
        if(sharer.name == "Info"){
            //跳转到信息页面
            self.tabBarController?.selectedIndex = 0
        }else if(sharer.name == "Add"){
            //跳转到添加页面
            self.tabBarController?.selectedIndex = 2
        }else if(sharer.name == "Sync"){
            //刷新数据
            self.reloadTable()
        }else if(sharer.name == "Login"){
            //显示登录页面
            let view = LoginView(frame:CGRectMake(50, -350, self.view.frame.width-100, 350))

            self.view.addSubview(view)
            self.view.bringSubviewToFront(view)
            UIView.animateWithDuration(0.6, animations: {
                view.holderView.center = self.view.center
            })
        }else if(sharer.name == "Log Out"){
            //登出操作
            if(loginStatus == "yes"){
                let alert = SCLAlertView()
                alert.addButton("保留数据"){
                    //这会删除上一个本地用户的数据
                    outgoingManager.syncToLocal()
                    PFUser.logOut()
                    userName = "un-usered"
                    loginStatus = "no"
                    self.userLabel.text = userName
                }
                alert.addButton("清空数据"){
                    userName = "un-usered"
                    loginStatus = "no"
                    PFUser.logOut()
                    self.userLabel.text = userName
                    self.reloadTable()
                }
                alert.showInfo("您将登出", subTitle: "是否清空本地数据？",closeButtonTitle:"取消登出")
            }
        }
    }
    //****** 小圆球执行的事件将在这里进行 ******

    override func viewDidLoad() {
        super.viewDidLoad()

        outgoingTable.tag = 19
        outgoingTable.reloadData()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? OutgoingDetailViewController
        }
        //PFUser.requestPasswordResetForEmail("fy66@scarletmail.rutgers.edu")
        
        //设置tableview分割线不显示
        outgoingTable.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    //returning the view
    override func viewWillAppear(animated: Bool) {
        userLabel.text = userName
        outgoingTable.reloadData()
        self.tabBarController?.tabBar.hidden = true
    }
    
    //****** tableView 相关 ******
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "show detail"){
            //let indexPath = self.outgoingTable.indexPathForCell(sender as! OutgoingCell)
            let indexPath = self.outgoingTable.indexPathForSelectedRow()
            
            let cell = outgoingTable.cellForRowAtIndexPath(indexPath!) as! OutgoingCell
            //println(cell.nameLabel.text)

            let dvc:OutgoingDetailViewController! = segue.destinationViewController as! OutgoingDetailViewController
            //let dvc = segue.destinationViewController
            //println(userName)
            let cost = (cell.costLabel.text! as NSString).doubleValue
            dvc.detailItem = outgoing(id: cell.id!, name: cell.nameLabel.text!, desc: cell.descLabel.text!, cost: cost,user: userName,date:cell.date!)
            println(cell.id)
            //segue.destinationViewController = rootVC
            
            
            //dvc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            //dvc.navigationItem.leftItemsSupplementBackButton = true

        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OutgoingCell", forIndexPath: indexPath) as! OutgoingCell
        cell.id = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].id
        cell.nameLabel.text = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].name
        cell.descLabel.text = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].desc
        let cost = String(stringInterpolationSegment:outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].cost)
        cell.costLabel.text = cost
        cell.date = outgoingManager.outgoings[outgoingManager.outgoings.count-1-indexPath.row].date
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
    //****** tableView 相关 ******
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /*
        if self.tabBarController?.tabBar.hidden == true{
            UIView.animateWithDuration(2, animations:
                {self.tabBarController?.tabBar.hidden = false}
            )
        }else{
            self.tabBarController?.tabBar.hidden = true
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

