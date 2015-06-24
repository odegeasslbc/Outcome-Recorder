//
//  Outgoing.swift
//  记账
//
//  Created by 刘炳辰 on 15/6/19.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//
import UIKit
import Foundation
import Parse

let outgoingManager: OutgoingManager = OutgoingManager()

struct outgoing {
    var name = "un-named"
    var desc = "un-described"
    var cost = "0"
    var user = "un-usered"
}

class OutgoingManager:NSObject {
    let db = SQLiteDB.sharedInstance()

    var outgoings = [outgoing]()
    
    override init(){
        super.init()
        if loginStatus == "no"{
            let db = SQLiteDB.sharedInstance()
            //db.execute("drop table outgoings")
            db.execute("create table if not exists outgoings(id integer primary key,name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
            let data = db.query("select * from outgoings where user = 'un-usered'")
            for item in data{
                let outgoingItem = item as SQLRow
                let newName = outgoingItem["name"]?.asString()
                let newDesc = outgoingItem["desc"]?.asString()
                let newCost = outgoingItem["cost"]?.asString()
                let newUser = outgoingItem["user"]?.asString()
                self.addOutgoing(newName!, desc: newDesc!, cost: newCost!,user: newUser!)
            }
        }
        else if loginStatus == "yes"{
            
            var query = PFQuery(className:"Outgoing")
            query.whereKey("user", equalTo:PFUser.currentUser()!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            var name = object["name"] as! String
                            var desc = object["desc"] as! String
                            var cost = object["cost"] as! String
                            //println("\(name) , \(desc), \(cost)")
                            outgoingManager.addOutgoing(name, desc: desc, cost: "\(cost)",user:userName)
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }
    
    func addOutgoing(name:String,desc:String,cost:String,user:String){
        outgoings.append(outgoing(name: name, desc: desc, cost: cost,user: user))
    }
    
    func removeOutgoing(index:Int){
        outgoings.removeAtIndex(index)
    }
    
    func refreshOutgoings(){
        outgoingManager.outgoings.removeAll(keepCapacity: true)
        if loginStatus == "yes"{
            var query = PFQuery(className: "Outgoing")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.findObjectsInBackgroundWithBlock{
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            var name = object["name"] as! String
                            var desc = object["desc"] as! String
                            var cost = object["cost"] as! String
                        //println("\(name) , \(desc), \(cost)")
                            outgoingManager.addOutgoing(name, desc: desc, cost: "\(cost)",user:userName)
                        }
                    }
                } else {
                // Log details of the failure
                //println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
        else{
            let db = SQLiteDB.sharedInstance()
            //db.execute("drop table outgoings")
            db.execute("create table if not exists outgoings(id integer primary key,name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
            let data = db.query("select * from outgoings where user = 'un-usered'")
            for item in data{
                let outgoingItem = item as SQLRow
                let newName = outgoingItem["name"]?.asString()
                let newDesc = outgoingItem["desc"]?.asString()
                let newCost = outgoingItem["cost"]?.asString()
                let newUser = outgoingItem["user"]?.asString()
                self.addOutgoing(newName!, desc: newDesc!, cost: newCost!,user: newUser!)
            }

        }
        //println(outgoingManager.outgoings)
    }
    
    func syncToCloud(){
        var newOutgoings = [outgoing]()
        let db = SQLiteDB.sharedInstance()
        //db.execute("drop table outgoings")
        //db.execute("create table if not exists outgoings(id integer primary key,name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
        let data = db.query("select * from outgoings where user = 'un-usered'")
        for item in data{
            let outgoingItem = item as SQLRow
            let newName = outgoingItem["name"]?.asString()
            let newDesc = outgoingItem["desc"]?.asString()
            let newCost = outgoingItem["cost"]?.asString()
            let newUser = outgoingItem["user"]?.asString()
            newOutgoings.append(outgoing(name: newName!, desc: newDesc!, cost: newCost!,user: newUser!))
        }
        
        for item in newOutgoings{
            var outgoing = PFObject(className: "Outgoing")
            outgoing["name"] = item.name
            outgoing["desc"] = item.desc
            outgoing["cost"] = item.cost
            outgoing["user"] = PFUser.currentUser()
            outgoing.save()
        }
    }
    
    func syncToLocal(){
        let db = SQLiteDB.sharedInstance()
        db.execute("drop table outgoings")
        db.execute("create table if not exists outgoings(id integer primary key,name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
        for item in outgoings{
            let sql = "insert into outgoings(name,desc,cost,user) values ('\(item.name)','\(item.desc)','\(item.cost)','un-usered')"
            let result = db.execute(sql)
        }
        
    }
    
    func saveAll(){
        let db = SQLiteDB.sharedInstance()
        db.execute("drop table outgoings")
        db.execute("create table if not exists outgoings(id integer primary key,name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
        for item in outgoings{
            let sql = "insert into outgoings(name,desc,cost,user) values ('\(item.name)','\(item.desc)','\(item.cost)','\(item.user)')"
            let result = db.execute(sql)
        }
        //println("save success")
    }
    
    func saveOnCloud(){
        if loginStatus == "yes"{
            
            //删除所有云端数据，再写入新的数据
            var query = PFQuery(className: "Outgoing")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.findObjectsInBackgroundWithBlock{
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                }
            }
            //写入新的数据
            for item in self.outgoings{
            var outgoing = PFObject(className: "Outgoing")
            outgoing["name"] = item.name
            outgoing["desc"] = item.desc
            outgoing["cost"] = item.cost
            outgoing["user"] = PFUser.currentUser()
            outgoing.save()
            }
        }
    }
}