//
//  OutgoingCell.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//

import UIKit

class OutgoingCell: UITableViewCell {
    var test:String!
    
    @IBOutlet var halfView: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    var date:NSDate?
    
    var id:String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 10
        //halfView.layer.cornerRadius = 8.8
        //costLabel.clipsToBounds = true
        //costLabel.layer.cornerRadius = 45
        
        //self.contentView.addSubview(backgroundLabel)
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
