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

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    
    @IBOutlet var logoutBtn: UIButton!
    @IBOutlet var registerBtn: UIButton!
    @IBOutlet var loginBtn: UIButton!
    
    
    @IBAction func loginButton(sender: AnyObject) {
        self.view.endEditing(true)
        
        let alert = SCLAlertView()
        //在新用户登录前把当前用户数据保存
        //outgoingManager.saveOnCloud()
        
        PFUser.logInWithUsernameInBackground(nameText.text, password: passwordText.text){
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                loginStatus = "yes"
                userName = user!.username!
                alert.showInfo("成功", subTitle: "登录成功", closeButtonTitle: "好的", duration: 2.0)
                
                self.nameLabel.text = userName
                self.logoutBtn.hidden = false
                self.registerBtn.hidden = true
                self.loginBtn.hidden = true
                
                outgoingManager.refreshOutgoings()
            } else {
                // The login failed. Check error to see why.
                let errorString = error!.userInfo?["error"] as? String
                // Show the errorString somewhere and let the user try again.
                alert.showInfo("失败", subTitle: errorString!, closeButtonTitle: "好的")
            }
        }
        
        nameText.text = ""
        passwordText.text = ""
        emailText.text = ""
    }
    
    @IBAction func registerButton(sender: AnyObject) {
        self.view.endEditing(true)
        
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
                }
                alert.showInfo("成功", subTitle: "成功注册新用户！是否同步本地数据到该账户？", closeButtonTitle: "不了。新建空账户")
                
                self.logoutBtn.hidden = false
                self.registerBtn.hidden = true
                self.loginBtn.hidden = true
                
                self.nameLabel.text = userName

                outgoingManager.refreshOutgoings()
            }
        }
        
        nameText.text = ""
        passwordText.text = ""
        emailText.text = ""
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        let alert = SCLAlertView()
        alert.addButton("保留数据"){
            //这会删除上一个本地用户的数据
            outgoingManager.syncToLocal()
            PFUser.logOut()
            userName = "un-usered"
            loginStatus = "no"
            
            self.logoutBtn.hidden = true
            self.registerBtn.hidden = false
            self.loginBtn.hidden = false
        }
        alert.addButton("清空数据"){
            userName = "un-usered"
            loginStatus = "no"
            PFUser.logOut()
            outgoingManager.refreshOutgoings()
            
            self.logoutBtn.hidden = true
            self.registerBtn.hidden = false
            self.loginBtn.hidden = false
        }
        alert.showInfo("您将登出", subTitle: "是否清空本地数据？",closeButtonTitle:"取消登出")

        
        nameLabel.text = ""
        nameText.text = ""
        passwordText.text = ""
        emailText.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if PFUser.currentUser() != nil{
            userName = PFUser.currentUser()!.username!
            nameLabel.text = userName
        }
        
        if loginStatus == "no"{
            logoutBtn.hidden = true
        }else{
            loginBtn.hidden = true
            registerBtn.hidden = true
        }
        // Do any additional setup after loading the view.
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
