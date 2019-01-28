//
//  UserCell.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/11.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import Firebase

class UserCell:UITableViewCell{
    
    
    
    var message:Message? {
        
        didSet{
            
            self.fetchUserProfile()
            self.detailTextLabel?.text = message?.text ?? "a media message"
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "hh:mm:ss a"
            guard let seconds = message?.timestamp?.doubleValue else {return}
            let date = Date(timeIntervalSince1970: seconds)
            self.timeLabel.text = dateformatter.string(from: date)
         
            
        }
    }
    
    let timeLabel:UILabel = {
        let li = UILabel()
            li.translatesAutoresizingMaskIntoConstraints = false
            li.font = UIFont.systemFont(ofSize: 13)
            li.textColor = UIColor.darkGray
        return li
    }()
    
    
    fileprivate func fetchUserProfile(){
        
        guard let partnerID = message?.partnerId() else {return}
        
        Database.database().reference().child("User").child(partnerID).observeSingleEvent(of: .value) { (snapshot) in
            guard let snap = snapshot.value as? [String:Any] else {return}
            let user = User(snap)
            self.textLabel?.text = user.name ?? ""
            guard let url = user.profileImageUrl else {return}
            self.portrait.setupImageCacheWithURl(url)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let portrait:UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 24
        img.clipsToBounds = true
        
        return img
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(portrait)
        addSubview(timeLabel)
        setupView()
    }
    
    func setupView(){
        portrait.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        portrait.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        portrait.widthAnchor.constraint(equalToConstant: 48).isActive = true
        portrait.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: topAnchor ,constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
