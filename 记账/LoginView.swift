//
//  LoginView.swift
//  记账
//
//  Created by 刘炳辰 on 15/7/10.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class LoginView: UIView {
    
    var holderView:UIView!
    
    var nameText: UITextField!
    //var emailText: UITextField!
    var passwordText: UITextField!
    
    var registerBtn: UIButton!
    var closeBtn: UIButton!
    var loginBtn: UIButton!
    
    func register(){
        let view = RegisterView(frame: CGRectMake(50, -350, self.frame.width-100, 350))
        self.superview?.addSubview(view)
        self.superview?.bringSubviewToFront(view)
        UIView.animateWithDuration(0.6, animations: {
            view.holderView.center = self.superview!.center
        })
        self.removeFromSuperview()

    }
    
    func close(){
        UIView.animateWithDuration(0.7, animations: {
            self.holderView.center = CGPointMake(self.frame.width/2, 1000)
            }, completion:  {finished in self.removeFromSuperview()})
        
    }
    
    func login(){
        self.endEditing(true)
        
        let alert = SCLAlertView()
        
        PFUser.logInWithUsernameInBackground(nameText.text, password: passwordText.text){
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                loginStatus = "yes"
                userName = user!.username!
                alert.showInfo("成功", subTitle: "登录成功", closeButtonTitle: "好的", duration: 2.0)
                
                let vc = self.superview?.nextResponder() as! OutgoingListViewController
                vc.userLabel.text = userName
                vc.reloadTable()
                
                self.close()
                
            } else {
                // The login failed. Check error to see why.
                let errorString = error!.userInfo?["error"] as? String
                // Show the errorString somewhere and let the user try again.
                alert.showInfo("失败", subTitle: errorString!, closeButtonTitle: "好的")
            }
        }
        
        nameText.text = ""
        passwordText.text = ""
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
        
        loginBtn = UIButton(frame: CGRectMake(30, 180, frame.width-60, 35))
        loginBtn.backgroundColor = UIColor(red: 0, green: 0.784, blue: 0.94, alpha: 1)
        loginBtn.setTitle("登录", forState: UIControlState.Normal)
        loginBtn.setTitleColor(UIColor(red: 0, green: 0.66, blue: 0.94, alpha: 1), forState: UIControlState.Highlighted)
        loginBtn.layer.cornerRadius = 3
        loginBtn.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
        
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
        holderView.addSubview(passwordText)
        holderView.addSubview(loginBtn)
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
