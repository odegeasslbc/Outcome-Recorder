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
    var id = "un-ided"
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
        
        let db = SQLiteDB.sharedInstance()
        db.execute("drop table outgoings")
        db.execute("create table if not exists outgoings(id varchar(20) primary key,objectid varchar(20),name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
        let data = db.query("select * from outgoings where user = '\(userName)'")
        for item in data{
            let outgoingItem = item as SQLRow
            let newName = outgoingItem["name"]?.asString()
            let newDesc = outgoingItem["desc"]?.asString()
            let newCost = outgoingItem["cost"]?.asString()
            let newUser = outgoingItem["user"]?.asString()
            let newId = outgoingItem["objectid"]?.asString()
            //println(newId)
            self.outgoings.append(outgoing(id:newId!,name:newName!, desc: newDesc!, cost: newCost!,user: newUser!))
        }
        
        
    }
    
    //生成随机10位字符串，用作id进行对数组和数据库即云端数据的操作
    func createId()->String{
        var id = ""
        for i in 0...10 {
            var randomNumber = 65 + arc4random() % 26
            var randomCharacter = Character( UnicodeScalar(randomNumber))
            id += String(randomCharacter)
        }
        return id
    }
    
    func addOutgoing(id:String,name:String,desc:String,cost:String,user:String){
        if loginStatus == "yes"{
            var outgoing = PFObject(className: "Outgoing")
            outgoing["name"] = name
            outgoing["desc"] = desc
            outgoing["cost"] = cost
            outgoing["id"] = id
            outgoing["user"] = PFUser.currentUser()!
            outgoing.save()
        }
        
        outgoings.append(outgoing(id:id,name: name, desc: desc, cost: cost,user: user))
        db.execute("insert into outgoings(objectid,name,desc,cost,user) values ('\(id)','\(name)','\(desc)','\(cost)','\(user)')")
    }
    
    func removeOutgoing(index:Int){
        let id = self.outgoings[index].id
        if loginStatus == "yes"{
            var query = PFQuery(className: "Outgoing")
            query.whereKey("id", equalTo: id)
            query.findObjectsInBackgroundWithBlock(){
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                }
            }
        }
        db.execute("delete from outgoings where objectid='\(id)'")
        outgoings.removeAtIndex(index)
    }
    
    //新用户登录时触发，把云端数据同步到本地。或读取本地"无用户"的数据
    func refreshOutgoings(){
        outgoings.removeAll(keepCapacity: true)
        if loginStatus == "yes"{
            var query = PFQuery(className: "Outgoing")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.findObjectsInBackgroundWithBlock{
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            var id = object["id"] as! String
                            var name = object["name"] as! String
                            var desc = object["desc"] as! String
                            var cost = object["cost"] as! String
                        //println("\(name) , \(desc), \(cost)")
                            outgoingManager.addOutgoing(id, name:name, desc: desc, cost: cost,user:userName)
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
            db.execute("create table if not exists outgoings(id varchar(20) primary key,objectid varchar(20),name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
            let data = db.query("select * from outgoings where user = 'un-usered'")
            for item in data{
                let outgoingItem = item as SQLRow
                let newId = outgoingItem["id"]?.asString()
                let newName = outgoingItem["name"]?.asString()
                let newDesc = outgoingItem["desc"]?.asString()
                let newCost = outgoingItem["cost"]?.asString()
                let newUser = outgoingItem["user"]?.asString()
                self.addOutgoing(newId!,name:newName!, desc: newDesc!, cost: newCost!,user: newUser!)
            }

        }
        //println(outgoingManager.outgoings)
    }
    
    //把之前未注册用户的数据同步到云端
    func syncToCloudForFirstUser(){
        var newOutgoings = [outgoing]()
        let db = SQLiteDB.sharedInstance()
        //db.execute("drop table outgoings")
        //db.execute("create table if not exists outgoings(id integer primary key,name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
        let data = db.query("select * from outgoings where user = 'un-usered'")
        for item in data{
            let outgoingItem = item as SQLRow
            let newId = outgoingItem["id"]?.asString()
            let newName = outgoingItem["name"]?.asString()
            let newDesc = outgoingItem["desc"]?.asString()
            let newCost = outgoingItem["cost"]?.asString()
            let newUser = outgoingItem["user"]?.asString()
            newOutgoings.append(outgoing(id: newId!,name: newName!, desc: newDesc!, cost: newCost!,user: newUser!))
        }
        
        for item in newOutgoings{
            var outgoing = PFObject(className: "Outgoing")
            outgoing["id"] = createId()
            outgoing["name"] = item.name
            outgoing["desc"] = item.desc
            outgoing["cost"] = item.cost
            outgoing["user"] = PFUser.currentUser()
            outgoing.save()
        }
    }
    
    //用户登出时触发，把用户数据存为本地"无用户"数据,这会删除之前的数据
    func syncToLocal(){
        let db = SQLiteDB.sharedInstance()
        db.execute("drop table outgoings")
        db.execute("create table if not exists outgoings(id varchar(20) primary key,objectid varchar(20),name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
        for item in outgoings{
            let sql = "insert into outgoings(objectid,name,desc,cost,user) values ('\(item.id)','\(item.name)','\(item.desc)','\(item.cost)','un-usered')"
            let result = db.execute(sql)
        }
        
    }
    /*
    //保存当前用户的数据到云端
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
            outgoing["id"] = item.id
            outgoing["name"] = item.name
            outgoing["desc"] = item.desc
            outgoing["cost"] = item.cost
            outgoing["user"] = PFUser.currentUser()
            outgoing.save()
            }
        }
    }*/
}