//
//  CBViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/7/10.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//

import UIKit

class CBViewController: UIViewController,CFShareCircleViewDelegate {

    var shareCircleView:CFShareCircleView!
    var panView: UIView!
    var circleViewShow = false
    
    let tapRec = UITapGestureRecognizer()
    let panRec = UIPanGestureRecognizer()
    
    //414,736
    var panviewPosition:CGPoint = CGPointMake(314,600)
    
    func tappedView(sender:UIGestureRecognizer){
        shareCircleView.show()
    }
    
    func draggedView(sender:UIGestureRecognizer){
        
        var translation = panRec.translationInView(self.view)
        
        //monitor the position of the circle view ,not to go out of the screen
        if panView.center.x > self.view.frame.width - 25 {
            panView.center.x = self.view.frame.width - 25
        }
        if panView.center.x < 25{
            panView.center.x = 25
        }
        if panView.center.y > self.view.frame.height - 25 {
            panView.center.y = self.view.frame.height - 25
        }
        if panView.center.y < 77{
            panView.center.y = 77
        }
        
        panView.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
        panRec.setTranslation(CGPointZero, inView: self.view)
        self.panviewPosition = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
    }
    
    //what button in circleButtonView should do in this func
    func shareCircleView(aShareCircleView: CFShareCircleView!, didSelectSharer sharer: CFSharer!) {
        panView.center = panviewPosition
        if(sharer.name == "Facebook"){
            self.tabBarController?.selectedIndex = 0
        }else if(sharer.name == "Pinterest"){
            self.tabBarController?.selectedIndex = 2
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.tabBar.hidden = true
        
        panView = UIView(frame: CGRectMake(self.view.frame.width-80,self.view.frame.height-80,50,50))
        panView.backgroundColor = UIColor.lightGrayColor()
        panView.layer.cornerRadius = 25
        panView.alpha = 0.7
        panviewPosition = panView.center
        panView.userInteractionEnabled = true
        panView.addGestureRecognizer(panRec)
        panView.addGestureRecognizer(tapRec)
        
        panRec.addTarget(self,action:"draggedView:")
        tapRec.addTarget(self,action:"tappedView:")
        
        var roundView = UIView(frame: CGRectMake(12, 12, 26, 26))
        roundView.backgroundColor = UIColor.blackColor()
        roundView.layer.cornerRadius = 5
        roundView.alpha = 0.2
        panView.addSubview(roundView)
        
        self.view.addSubview(panView)
        self.view.bringSubviewToFront(panView)
        
        self.view.userInteractionEnabled = true
        
        if panView.center.x > self.view.frame.width/2{
            shareCircleView = CFShareCircleView(frame: self.view.frame ,location:CGPoint(x: 80, y: 200))
            shareCircleView.delegate = self
            self.view.addSubview(shareCircleView)
        }else{
            shareCircleView = CFShareCircleView(frame: self.view.frame ,location:CGPoint(x: -80, y: 200))
            shareCircleView.delegate = self
            self.view.addSubview(shareCircleView)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
