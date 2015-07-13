//
//  AddViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import Parse
import UIKit

class AddViewController: CBViewController, UITextFieldDelegate, TagViewDelegate {

    var tagButton:UIButton!
    var tagView:TagView!
    
    var nameOrDesc = 1
    
    @IBOutlet var costTextfield: UITextField!
    @IBOutlet var descTextfield: UITextField!
    @IBOutlet var nameTextfield: UITextField!
    
    @IBOutlet var userLabel: UILabel!
    
    func showTagView(){
        self.view.endEditing(true)
        if(tagView.isShowing == false){
            tagView.showWithAnim()
        }else{
            tagView.hideWithAnim()
        }
        
    }
    
    func drawText(tag: String) {
        
        if nameOrDesc == 1 {
            var current = self.nameTextfield.text
            self.nameTextfield.text = current + " " + tag
        }else if nameOrDesc == 2 {
            var current = self.descTextfield.text
            self.descTextfield.text = current + " " + tag
        }
        

    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        nameOrDesc = textField.tag
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        nameOrDesc = textField.tag
    }
    
    @IBAction func addButton(sender: AnyObject) {
        let id = createId()
        let cost = (costTextfield.text! as NSString).doubleValue
        
        //let fourHours = NSTimeInterval(60*60*4)
        //let date = NSDate(timeInterval:-fourHours,sinceDate: NSDate())
        
        let date = NSDate()
        outgoingManager.addOutgoing(id,name: nameTextfield.text,desc:descTextfield.text,cost:cost,user:userName,date:date)
        self.view.endEditing(true)
        costTextfield.text = " "
        descTextfield.text = " "
        nameTextfield.text = " "
        self.tabBarController?.selectedIndex = 1;
    }
    
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //给每一个item生成独一无二的10位随机字符串
    func createId()->String{
        var id = ""
        for i in 0...10 {
            var randomNumber = 65 + arc4random() % 26
            var randomCharacter = Character( UnicodeScalar(randomNumber))
            id += String(randomCharacter)
        }
        return id
    }
    
    override func viewWillAppear(animated: Bool) {
        userLabel.text = userName
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidLoad() {
        costTextfield.text = " "
        descTextfield.text = " "
        nameTextfield.text = " "
        
        nameTextfield.delegate = self
        descTextfield.delegate = self
        costTextfield.delegate = self
        
        tagButton = UIButton(frame: CGRectMake(self.view.frame.width-100, 250, 70, 30))
        tagButton.setTitle("Tag", forState: UIControlState.Normal)
        tagButton.backgroundColor = UIColor.darkGrayColor()
        tagButton.addTarget(self, action: "showTagView", forControlEvents: UIControlEvents.TouchUpInside)
        
        tagView = TagView(point: CGPointMake(tagButton.frame.minX, tagButton.frame.minY))
        tagView.delegate = self

        self.view.addSubview(tagView)
        self.view.addSubview(tagButton)
        super.viewDidLoad()

        //self.view.sendSubviewToBack(tagButton)
        //self.view.sendSubviewToBack(tagView)
        
        self.tabBarController?.tabBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        tagView.hideWithAnim()

    }

}
