//
//  InfoViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class InfoViewController: UIViewController,UITextFieldDelegate {

    var currentMoney:Double = 1700
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var currentMoneyLabel: UILabel!
    @IBOutlet var totalOutgoingLabel: UILabel!
    
    
    func countTotal()->String{
        var totalCount:Double = 0.0

        for item in outgoingManager.outgoings{
            let cost = item.cost
            totalCount += cost
        }
        let tmp:Double = 1700.00
        currentMoney = tmp - totalCount

        return String(stringInterpolationSegment: totalCount)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        nameLabel.text = "un-usered"
        
        if PFUser.currentUser() != nil{
            userName = PFUser.currentUser()!.username!
            nameLabel.text = userName
        }

        totalOutgoingLabel.text = countTotal()
        
    }

    override func viewWillAppear(animated: Bool) {
        if(firstOpen == true){
            self.tabBarController?.selectedIndex = 2
        }
        
        nameLabel.text = userName
        totalOutgoingLabel.text = countTotal()
        currentMoneyLabel.text = String(stringInterpolationSegment: currentMoney)
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


