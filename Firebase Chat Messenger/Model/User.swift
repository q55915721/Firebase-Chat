//
//  User.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/4.
//  Copyright © 2018 洪森達. All rights reserved.
//

import Foundation
import Firebase

class User:NSObject{
    var name:String?
    var email:String
    var profileImageUrl: String?
    var uid:String?
    
    init(_ dictionary:[String:Any]){
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageUrl = dictionary["ProfileImageURl"] as? String ?? ""
    }
    
    class func currentUser() -> String {
        
        return Auth.auth().currentUser?.uid ?? "" 
    }
}
