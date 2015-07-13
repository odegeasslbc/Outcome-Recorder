//
//  InfoViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class InfoViewController: CBViewController,UITextFieldDelegate {

    var bgImg: UIImageView!
    var topView: UIView!
    var currentMoney:Double = 1700
    
    
    var userLabel: UILabel!
    var currentMoneyLabel: UILabel!
    var totalOutgoingLabel: UILabel!
    
    
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
            if(loginStatus == "yes"){
                //self.reloadTable()
            }
            self.tabBarController?.selectedIndex = 1
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
                    //self.reloadTable()
                }
                alert.showNotice("您将登出", subTitle: "是否清空本地数据？",closeButtonTitle:"取消登出")
            }
        }
    }
    //****** 小圆球执行的事件将在这里进行 ******
    
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
        
        topView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 51))
        topView.backgroundColor = UIColor.darkGrayColor()
        topView.alpha = 0.4
        
        bgImg = UIImageView(frame: self.view.frame)
        bgImg.image = UIImage(named: "bgblue")
        
        userLabel = UILabel(frame: CGRectMake(self.view.frame.width-128, 20, 128, 31))
        userLabel.font = UIFont.systemFontOfSize(22)
        userLabel.textAlignment = NSTextAlignment.Center
        userLabel.textColor = UIColor.lightGrayColor()
        
        currentMoneyLabel = UILabel(frame: CGRectMake(100, 250, self.view.frame.width-200, 60))
        currentMoneyLabel.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        currentMoneyLabel.textAlignment = NSTextAlignment.Center
        totalOutgoingLabel = UILabel(frame: CGRectMake(100, 340, self.view.frame.width-200, 60))
        totalOutgoingLabel.textAlignment = NSTextAlignment.Center
        totalOutgoingLabel.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        
        self.view.addSubview(bgImg)
        self.view.addSubview(topView)
        self.view.addSubview(userLabel)
        self.view.addSubview(currentMoneyLabel)
        self.view.addSubview(totalOutgoingLabel)
        
        userLabel.text = "un-usered"
        
        if PFUser.currentUser() != nil{
            userName = PFUser.currentUser()!.username!
            userLabel.text = userName
        }

        totalOutgoingLabel.text = countTotal()
        super.viewDidLoad()
        //self.view.bringSubviewToFront(panView)


    }

    override func viewWillAppear(animated: Bool) {
        if(firstOpen == true){
            self.tabBarController?.selectedIndex = 2
        }
        
        userLabel.text = userName
        totalOutgoingLabel.text = countTotal()
        currentMoneyLabel.text = String(stringInterpolationSegment: currentMoney)
        self.tabBarController?.tabBar.hidden = true

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


