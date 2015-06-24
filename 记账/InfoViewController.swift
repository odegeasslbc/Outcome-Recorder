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
    
    @IBAction func loginButton(sender: AnyObject) {
        self.view.endEditing(true)
        
        let alert = SCLAlertView()
        
        PFUser.logInWithUsernameInBackground(nameText.text, password: passwordText.text){
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                loginStatus = "yes"
                userName = user!.username!
                self.nameLabel.text = user!.username
                alert.showInfo("成功", subTitle: "登录成功", closeButtonTitle: "好的", duration: 2.0)
                outgoingManager.refreshOutgoings()
            } else {
                // The login failed. Check error to see why.
                let errorString = error?.description
                // Show the errorString somewhere and let the user try again.
                alert.showInfo("失败", subTitle: errorString!, closeButtonTitle: "好的", duration: 2.0)
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
                alert.showInfo("失败", subTitle: errorString!, closeButtonTitle: "好的", duration: 2.0)
            } else {
                alert.addButton("是的，同步我的数据"){
                    PFUser.logInWithUsernameInBackground(user.username!, password: user.password!)
                    userName = user.username!
                    loginStatus = "yes"
                    outgoingManager.syncToCloud()
                }
                alert.showInfo("成功", subTitle: "成功注册新用户！是否同步本地数据到该账户？", closeButtonTitle: "不了。新建空账户")
                
                outgoingManager.refreshOutgoings()
            }
        }
        
        nameLabel.text = user.username
        nameText.text = ""
        passwordText.text = ""
        emailText.text = ""
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        PFUser.logOut()
        userName = "un-usered"
        loginStatus = "no"
        let alert = SCLAlertView()
        alert.addButton("清空数据"){
            let db = SQLiteDB.sharedInstance()
            db.execute("drop table outgoings")
            outgoingManager.outgoings.removeAll(keepCapacity: true)
        }
        alert.showInfo("您已登出", subTitle: "是否清空本地数据？", closeButtonTitle: "保留数据")
        outgoingManager.syncToLocal()
        
        nameLabel.text = ""
        nameText.text = ""
        passwordText.text = ""
        emailText.text = ""
        outgoingManager.refreshOutgoings()
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
