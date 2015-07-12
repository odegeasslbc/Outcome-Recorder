//
//  OutgoingDetailViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/24.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//

import UIKit


class OutgoingDetailViewController: UIViewController {

    @IBOutlet var userLabel: UILabel!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    //var delegate: OutgoingDetailViewControllerDelegate?
    //var outgoingInfo:OutgoingInfo!
    var detailItem: outgoing? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: outgoing = self.detailItem {
            if let label = self.userLabel {
                label.text = detail.user
            }
            if let label = self.descLabel{
                label.text = detail.desc
            }
            if let label = self.costLabel{
                label.text = String(stringInterpolationSegment: detail.cost)
            }
            if let label = self.nameLabel{
                label.text = detail.name
            }
            if let label = self.dateLabel{
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = dateFormatter.stringFromDate(detail.date)
                label.text = dateString
            }
        }
    }
    
    func swippedDown(){
        //self.tabBarController?.tabBar.hidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.navigationController?.popViewControllerAnimated(true)
        
        
        let swipeDownRec = UISwipeGestureRecognizer()
        swipeDownRec.direction = UISwipeGestureRecognizerDirection.Down
        swipeDownRec.addTarget(self,action:"swippedDown")
        self.view.addGestureRecognizer(swipeDownRec)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
