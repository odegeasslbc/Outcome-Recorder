# outcome-recorder
operate with both local data storage and cloud data management

##Description:
This app is an recorder to help evaluate and calculate where and how the user spend his/her money in daily life.

![alt tag](https://cloud.githubusercontent.com/assets/9973368/13720911/3efd17e4-e7e4-11e5-901a-d0a395538d22.gif)

##Technical Specs
It is an cloud based app that using the platform provided by Pares (https://parse.com/) to maintain the data storage

Thanks a lot for the api provided by Parse

It is also support local storage by sqlite database

###1. User System
![alt tag](https://cloud.githubusercontent.com/assets/9973368/13720969/0e5138da-e7e6-11e5-8a4e-e677c048b35e.gif)
user register
```swift
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
                let errorString = error.userInfo["error"] as? String
                // Show the errorString somewhere and let the user try again.
                alert.showError("Fail", subTitle: errorString!, closeButtonTitle: "ok")
            } else {
                alert.addButton("yes, sync my data"){
                    PFUser.logInWithUsernameInBackground(user.username!, password: user.password!)
                    userName = user.username!
                    loginStatus = "yes"
                    outgoingManager.syncToCloudForFirstUser()
                    
                    self.close()
                }
                alert.showSuccess("success", subTitle: "congratulation！do you want to sync all your data into this new account？", closeButtonTitle: "no, just create an new account")
                
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
```

###2. Data to local
![alt tag](https://cloud.githubusercontent.com/assets/9973368/13720914/463fc330-e7e4-11e5-9ab5-cf5688dad323.gif)
```swift
    func syncToLocal(){
        let db = SQLiteDB.sharedInstance()
        db.execute("drop table outgoings")
        db.execute("create table if not exists outgoings(id varchar(20) primary key,objectid varchar(20),name varchar(20),desc varchar(20),cost number(20),user varchar(20),date DATETIME)")
        for item in outgoings{
            let sql = "insert into outgoings(objectid,name,desc,cost,user,date) values ('\(item.id)','\(item.name)','\(item.desc)','\(item.cost)','un-usered','\(item.date)')"
            _ = db.execute(sql)
        }
        
    }
    
    func saveToLocal(){
        let db = SQLiteDB.sharedInstance()
        db.execute("delete from outgoings where user = '\(userName)'")
        db.execute("create table if not exists outgoings(id varchar(20) primary key,objectid varchar(20),name varchar(20),desc varchar(20),cost number(20),user varchar(20),date DATETIME)")
        for item in outgoings{
            let sql = "insert into outgoings(objectid,name,desc,cost,user,date) values ('\(item.id)','\(item.name)','\(item.desc)','\(item.cost)','\(userName)','\(item.date)')"
            let result = db.execute(sql)
        }
        print("save success")
    }
```

###3. Data to cloud

query data from cloud server
```swift 
   func syncWithCloud() -> Bool {
        outgoings.removeAll(keepCapacity: false)
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
                            var date = object["date"] as! NSDate
                            var cost = object["cost"] as? Double
                                //println("\(name) , \(desc), \(cost)")
                            self.outgoings.append(outgoing(id:id,name:name, desc: desc, cost: cost!,user: userName,date: date))
                        }
                        
                    }
                }else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
            
            return true
        }
        return false
    }
```

save data to cloud server
```swift
    func syncToCloudForFirstUser(){
        var newOutgoings = [outgoing]()
        let db = SQLiteDB.sharedInstance()
        //db.execute("drop table outgoings")
        //db.execute("create table if not exists outgoings(id integer primary key,name varchar(20),desc varchar(20),cost varchar(20),user varchar(20))")
        let data = db.query("select * from outgoings where user = 'un-usered'")
        for item in data{
            let outgoingItem = item as SQLRow
            let newId = outgoingItem["objectid"]?.asString()
            let newName = outgoingItem["name"]?.asString()
            let newDesc = outgoingItem["desc"]?.asString()
            let newCost = outgoingItem["cost"]?.asDouble()
            let newUser = outgoingItem["user"]?.asString()
            let newDate = outgoingItem["date"]?.asDate()
            newOutgoings.append(outgoing(id: newId!,name: newName!, desc: newDesc!, cost: newCost!,user: newUser!,date: newDate!))
        }
        
        for item in newOutgoings{
            let outgoing = PFObject(className: "Outgoing")
            outgoing["id"] = createId()
            outgoing["name"] = item.name
            outgoing["desc"] = item.desc
            outgoing["cost"] = item.cost
            outgoing["date"] = item.date
            outgoing["user"] = PFUser.currentUser()
            outgoing.save()
        }
    }
```
