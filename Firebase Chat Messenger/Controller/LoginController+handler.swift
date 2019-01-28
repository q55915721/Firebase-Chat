//
//  LoginController+handler.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/5.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import Firebase

extension LoginController:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    @objc func handleImageProfile(){
        let picker = UIImagePickerController()
            picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
        
    }
    
    
    
    func handleRegister(){
        guard let email = emailLabel.text ,let name = nameLabel.text , let password = passwordsLabel.text else {
            print("form isn't valid.")
            return}
        Auth.auth().createUser(withEmail: email , password: password) { (user, error) in
            if let err = error  {
                print("error in create,",err)
                return
            }
            
            guard let userId = user?.user.uid else {return}
            print("successfully create user")
            
            let fileName = UUID().uuidString + "JPGE"
            let storage = Storage.storage().reference().child(userId).child(fileName)
            
            guard let imageData = self.profileImageView.image?.jpegData(compressionQuality: 0.1) else {return}
            storage.putData(imageData, metadata: nil, completion: { (meta, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                storage.downloadURL(completion: { (url, error) in
                    guard let url = url else{return}
                    let values = ["email":email,"name":name,"ProfileImageURl":url.absoluteString]
                    self.updateUser(uid: userId, values: values)
                    self.messageCOntrooler?.setupNavigationTitle()
                })
            })

        }
    }
    
    func updateUser(uid:String,values:[String:Any]){
         let database = Database.database().reference()
        let child = database.child("User").child(uid)
        child.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let err = error {
                print("error in update",err)
            }
            self.dismiss(animated: true, completion: nil)
            print("Successfully update user's data")
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = createDictionaryFromInfo(info)
        var img:UIImage?
        
        if let editedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            img = editedImg
        }else if let originImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            img = originImg
        }
        
        if let profile = img  {
            
            profileImageView.image = profile
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func createDictionaryFromInfo(_ info:[UIImagePickerController.InfoKey:Any]) ->[String:Any]{
        return Dictionary(uniqueKeysWithValues: info.map{key,value in (key.rawValue,value)})
    }
    
}
