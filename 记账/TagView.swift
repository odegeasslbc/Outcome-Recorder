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
        
        UIView.transitionWithView(self.tagView, duration: 0.4, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.tagView.frame = self.originFrame!
            var i:CGFloat = 10
            for btn in self.tags{
                btn.frame = CGRectMake(10, i, 60, 20)
                i += 30
            }
            }, completion: {
                finished in self.isShowing = true
        })
    }
    
    func hideWithAnim(){
       
        UIView.transitionWithView(self.tagView, duration: 0.4, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.tagView.frame = CGRectMake(0, 0, self.frame.width, 30)
            for btn in self.tags{
                btn.frame = CGRectMake(10, 10, 60, 20)
            }
            }, completion: {
            finished in self.isShowing = false
        })
    }
    
    func tagText(sender:UIButton){
        self.delegate?.drawText(sender.titleLabel!.text!)
    }
    
    init(point:CGPoint) {
        var height = CGFloat(tagManager.tags.count*30 + 10)
        
        super.init(frame: CGRectMake(point.x, point.y, 80, height))
        self.userInteractionEnabled = true

        isShowing = false
        
        tagView = UIView(frame: CGRectMake(0, 0, self.frame.width, 30))
        tagView.backgroundColor = UIColor.darkGrayColor()
        self.addSubview(tagView)
        originFrame = CGRectMake(0, 0, self.frame.width, height)

        for tag in tagManager.tags {
            let btn = UIButton(frame: CGRectMake(10, 10, 60, 20))
            btn.layer.cornerRadius = 5
            btn.titleLabel?.font = UIFont.systemFontOfSize(15)
            btn.backgroundColor = UIColor(red: 1, green: 0.9, blue: 0.58, alpha: 1)
            btn.setTitle(tag, forState: UIControlState.Normal)
            btn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted)
            btn.addTarget(self, action: "tagText:", forControlEvents: UIControlEvents.TouchDown)
            self.tags.append(btn)
            self.tagView.addSubview(btn)
        }
        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
