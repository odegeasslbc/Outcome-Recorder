//
//  StickerView.swift
//  naviBar
//
//  Created by 刘炳辰 on 15/7/12.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//

import UIKit

var tagManager = TagManager()

protocol TagViewDelegate{
    func drawText(tag:String)
}

class TagView: UIView {
    
    var blockView:UIView!
    var tagView:UIView!
    var originFrame:CGRect?
    var tags = [UIButton]()
    
    var isShowing:Bool?
    
    var delegate: TagViewDelegate?
    
    func hide(){
        self.frame = CGRectMake(self.frame.minX, self.frame.minY-self.frame.height, self.frame.width, self.frame.height)
        //for btn in tags{ btn.removeFromSuperview() }
    }

    func showWithAnim(){
        self.tagView.userInteractionEnabled = true
        UIView.animateWithDuration(0.6, animations: { self.tagView.frame = self.originFrame! }, completion: {finished in self.bringSubviewToFront(self.tagView)})
        self.isShowing = true
    }
    
    func hideWithAnim(){
        self.bringSubviewToFront(blockView)
        UIView.animateWithDuration(0.6, animations: { self.tagView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height/2)})
        self.isShowing = false
    }
    
    func tagText(sender:UIButton){
        self.delegate?.drawText(sender.titleLabel!.text!)
    }
    
    init(point:CGPoint) {
        var height = CGFloat(tagManager.tags.count*30 + 10)
        
        super.init(frame: CGRectMake(point.x, point.y-height, 70, height*2))
        self.userInteractionEnabled = true

        isShowing = false
        
        blockView = UIView(frame: CGRectMake(0, 0, self.frame.width, height))
        blockView.backgroundColor = UIColor.whiteColor()
        self.addSubview(blockView)
        
        tagView = UIView(frame: CGRectMake(0, 0, self.frame.width, height))
        tagView.backgroundColor = UIColor.darkGrayColor()
        self.addSubview(tagView)
        originFrame = CGRectMake(0, height, self.frame.width, height)
        
        self.bringSubviewToFront(blockView!)

        //self.layer.cornerRadius = 10
        
        var i:CGFloat = 10
        for tag in tagManager.tags {
            let btn = UIButton(frame: CGRectMake(10, i, 50, 20))
            btn.layer.cornerRadius = 5
            btn.titleLabel?.font = UIFont.systemFontOfSize(15)
            btn.backgroundColor = UIColor(red: 1, green: 0.9, blue: 0.58, alpha: 1)
            btn.setTitle(tag, forState: UIControlState.Normal)
            btn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted)
            btn.addTarget(self, action: "tagText:", forControlEvents: UIControlEvents.TouchDown)
            tagView.addSubview(btn)
            self.tags.append(btn)
            i += 30
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
