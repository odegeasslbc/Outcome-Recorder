//
//  TagManager.swift
//  naviBar
//
//  Created by 刘炳辰 on 15/7/12.
//  Copyright (c) 2015年 刘炳辰. All rights reserved.
//

import Foundation

class TagManager{
    var tags = [String]()
    
    init(){
        tags.append("吃饭")
        tags.append("购物")
        tags.append("电子")
        tags.append("衣服")
        tags.append("借钱")
        tags.append("运动")
    }
    
    func addTag(newTag: String){
        tags.append(newTag)
    }
}