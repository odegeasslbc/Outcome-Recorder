//
//  RegisterView.swift
//  记账
//
//  Created by 刘炳辰 on 15/7/10.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class RegisterView: UIView {
    var holderView:UIView!
    var nameText: UITextField!
    var emailText: UITextField!
    var passwordText: UITextField!
    var registerBtn: UIButton!
    var closeBtn: UIButton!
    
    func register(){
        self.endEditing(true)
        
        let alert = SCLAlertView()
        
        var user = PFUser()
        user.username = nameText.text
        user.password = passwordText.text
        user.email = emailText.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo?["error"] as? String
                // Show the errorString somewhere and let the user try again.
                alert.showInfo("失败", subTitle: errorString!, closeButtonTitle: "好的")
            } else {
                alert.addButton("是的，同步我的数据"){
                    PFUser.logInWithUsernameInBackground(user.username!, password: user.password!)
                    userName = user.username!
                    loginStatus = "yes"
                    outgoingManager.syncToCloudForFirstUser()
                    
                    self.close()
                }
                alert.showInfo("成功", subTitle: "成功注册新用户！是否同步本地数据到该账户？", closeButtonTitle: "不了。新建空账户")
                
                PFUser.logInWithUsernameInBackground(user.username!, password: user.password!)
                userName = user.username!
                loginStatus = "yes"
                outgoingManager.refreshOutgoings()
                
                let vc = self.superview?.nextResponder() as! OutgoingListViewController
                vc.userLabel.text = userName

                self.close()
                
            }
        }
        
        nameText.text = ""
        passwordText.text = ""
        emailText.text = ""
    }
    
    func close(){
        UIView.animateWithDuration(0.7, animations: {
            self.holderView.center = CGPointMake(self.frame.width/2, 1000)
            }, completion:  {finished in self.removeFromSuperview()})
        
    }
    
    override init(frame: CGRect) {
        super.init(frame:CGRectMake(0, 0, UIScreen.mainScreen().applicationFrame.width, UIScreen.mainScreen().applicationFrame.height+20 ))
        
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0.9
        
        holderView = UIView(frame: frame)
        holderView.backgroundColor = UIColor.blackColor()
        holderView.layer.cornerRadius = 10
        holderView.alpha = 0.8
        
        nameText = UITextField(frame: CGRectMake(30, 50, frame.width-60, 40))
        nameText.backgroundColor = UIColor.whiteColor()
        nameText.placeholder = "  name"
        nameText.borderStyle = UITextBorderStyle.RoundedRect
        
        passwordText = UITextField(frame: CGRectMake(30, 100, frame.width-60, 40))
        passwordText.backgroundColor = UIColor.whiteColor()
        passwordText.placeholder = "  password"
        passwordText.borderStyle = UITextBorderStyle.RoundedRect
        passwordText.secureTextEntry = true
        
        emailText = UITextField(frame: CGRectMake(30, 150, frame.width-60, 40))
        emailText.backgroundColor = UIColor.whiteColor()
        emailText.placeholder = "  email"
        emailText.borderStyle = UITextBorderStyle.RoundedRect
        
        registerBtn = UIButton(frame: CGRectMake(30, 225, frame.width-60, 35))
        registerBtn.backgroundColor = UIColor.greenColor()
        registerBtn.setTitle("注册", forState: UIControlState.Normal)
        registerBtn.setTitleColor(UIColor(red: 0, green: 0.7, blue: 0.15, alpha: 1), forState: UIControlState.Highlighted)
        registerBtn.layer.cornerRadius = 3
        registerBtn.addTarget(self, action: "register", forControlEvents: UIControlEvents.TouchUpInside)
        
        closeBtn = UIButton(frame: CGRectMake(frame.width-50, frame.height-40, 50, 40))
        closeBtn.backgroundColor = UIColor.blackColor()
        closeBtn.setTitle("返回", forState: UIControlState.Normal)
        closeBtn.titleLabel!.font = UIFont.systemFontOfSize(15)
        closeBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        closeBtn.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        
        holderView.addSubview(nameText)
        holderView.addSubview(emailText)
        holderView.addSubview(passwordText)
        holderView.addSubview(registerBtn)
        holderView.addSubview(closeBtn)
        
        self.addSubview(holderView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.endEditing(true)
    }
}
