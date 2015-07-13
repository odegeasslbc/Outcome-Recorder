//
//  AddViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate, TagViewDelegate {

    var tagButton:UIButton!
    var tagView:TagView!

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
        println(tag)
        var current = self.descTextfield.text
        self.descTextfield.text = current + " " + tag
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        userLabel.text = userName
        self.tabBarController?.tabBar.hidden = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        costTextfield.text = " "
        descTextfield.text = " "
        nameTextfield.text = " "
        
        var tagButton = UIButton(frame: CGRectMake(self.view.frame.width-100, 250, 70, 30))
        tagButton.setTitle("Tag", forState: UIControlState.Normal)
        tagButton.backgroundColor = UIColor.darkGrayColor()
        tagButton.addTarget(self, action: "showTagView", forControlEvents: UIControlEvents.TouchUpInside)
        
        tagView = TagView(point: CGPointMake(tagButton.frame.minX, tagButton.frame.minY+30))
        tagView.delegate = self

        self.view.addSubview(tagView)
        self.view.addSubview(tagButton)
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
