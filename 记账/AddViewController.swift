//
//  AddViewController.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var costTextfield: UITextField!
    @IBOutlet var descTextfield: UITextField!
    @IBOutlet var nameTextfield: UITextField!
    
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
