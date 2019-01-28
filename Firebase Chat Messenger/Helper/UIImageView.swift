//
//  UIImageView.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/5.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    
    func setupImageCacheWithURl(_ url:String){
        self.image = nil
        if let imageCh = imageCache.object(forKey: url as NSString) as? UIImage {
            self.image = imageCh
            return
        }
        
        guard let imageUrl = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else {return}
            DispatchQueue.main.async {
                if let profileImg = UIImage(data: data) {
                    imageCache.setObject(profileImg, forKey: url as NSString)
                    self.image = profileImg
                }
            }
        }.resume()
        
    }
}
