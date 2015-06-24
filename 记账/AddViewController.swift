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
        outgoingManager.addOutgoing(nameTextfield.text,desc:descTextfield.text,cost:costTextfield.text,user:userName)
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
