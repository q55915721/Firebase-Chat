//
//  Message.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/7.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    
    var fromId:String?
    var toId:String?
    var timestamp:NSNumber?
    var text:String?
    
    var imageUrl:String?
    var imageHeight:NSNumber?
    var imageWidth:NSNumber?
    var videoUrl:String?
    
    
    init(_ dictionary:[String:Any]){
        self.fromId = dictionary["FromId"] as? String
        self.toId = dictionary["ToId"] as? String
        self.timestamp = dictionary["Timestamp"] as? NSNumber
        self.text = dictionary["Text"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.videoUrl = dictionary["videoUrl"] as? String
    }
    
     func partnerId()->String? {
        
        return fromId == Auth.auth().currentUser?.uid ? toId:fromId
    }
}
