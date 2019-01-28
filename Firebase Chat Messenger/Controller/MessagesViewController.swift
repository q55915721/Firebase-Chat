//
//  ViewController.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/1.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {

    
    var messages = [Message]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupView()
        
        checkOutIfHasUser()
       
    }
    
    fileprivate func setupView(){
        
        
        view.backgroundColor = .white
        navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))]
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleToNewMessages))]
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellid)
    }
    
    fileprivate func observeMessages(){
        
        Database.database().reference().child("User-Messages").child(User.currentUser()).observe(.childAdded) { (snapshot) in
            let userid = snapshot.key
            
            Database.database().reference().child("User-Messages").child(User.currentUser()).child(userid).observe(.childAdded, with: { (snap) in
                let messageId = snap.key
                self.fetchMessageWith(messageId)
            })
        }
    }
    
    
    var messageDic = [String:Message]()
    
    fileprivate func fetchMessageWith(_ messageId:String){
        
        Database.database().reference().child("Messages").child(messageId).observeSingleEvent(of: .value) { (snap) in
            guard let dic = snap.value as? [String:Any] else {return}
            let message = Message(dic)
            
            if let partnerID = message.partnerId() {
                
                self.messageDic[partnerID] = message
               
                self.attempReloadDate()
            }
            
        }
        
        
    }
    
    fileprivate func attempReloadDate(){
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false)
        
        
    }
    
  @objc fileprivate func handleReload(){
        self.messages = Array(messageDic.values)
    self.messages.sort { (m1, m2) -> Bool in
        if let m1v = m1.timestamp , let m2v = m2.timestamp {
            return m1v.intValue > m2v.intValue
        }
        return false
      }
    
    DispatchQueue.main.async {
        self.tableView.reloadData()
    }
    
    }
    
    var timer: Timer?
    fileprivate let cellid = "cellId"
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let message = messages[indexPath.row]
        if let partnerID = message.partnerId() {
            
            Database.database().reference().child("User").child(partnerID).observeSingleEvent(of: .value) { (snap) in
                guard let dic = snap.value as? [String:Any] else {return}
                let user = User(dic)
                    user.uid = partnerID
                 self.showChatLogController(user)
            }
        }
       
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        
        cell.message = message
        return cell
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    
    
  @objc fileprivate func handleToNewMessages(){
        let new = NewMessageController()
            new.messageController = self
        let navigation = UINavigationController(rootViewController: new )
        present(navigation, animated: true, completion: nil)
    }
    
    fileprivate func checkOutIfHasUser(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            //title...
            setupNavigationTitle()
        }
    }
    
    func showChatLogController(_ user:User){
        let layout = UICollectionViewFlowLayout()
        let chatLog = ChatLogController(collectionViewLayout: layout)
            chatLog.user = user
        navigationController?.pushViewController(chatLog, animated: true)
    
    }
    
     func setupNavigationTitle(){
        
        messages.removeAll()
        messageDic.removeAll()
        self.tableView.reloadData()
        observeMessages()
        guard let userId = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("User").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let snap = snapshot.value as? [String:Any] else {return}
            
            let user = User(snap)
            
            self.navigationTitle(user)
        }
    }
    func navigationTitle(_ user:User){
        
        let titleView = UIView()
            titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        
        let profileVIew = UIImageView()
            containerView.addSubview(profileVIew)
        guard let userImageUrl = user.profileImageUrl else {return}
            profileVIew.setupImageCacheWithURl(userImageUrl)
            profileVIew.contentMode = .scaleAspectFill
            profileVIew.translatesAutoresizingMaskIntoConstraints = false
            profileVIew.layer.cornerRadius = 20
            profileVIew.clipsToBounds = true
       
        
        let nameLabel = UILabel()
        
            containerView.addSubview(nameLabel)
            nameLabel.text = user.name ?? ""
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        profileVIew.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileVIew.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileVIew.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileVIew.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileVIew.rightAnchor, constant: 8).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileVIew.heightAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileVIew.centerYAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        navigationItem.titleView = titleView
        
    }
    
    @objc fileprivate func handleLogout(){
        
        do{
            
            try Auth.auth().signOut()
       
        }catch let err{
            print("error in signOut...",err)
        }
        
        let loginController = LoginController()
        loginController.messageCOntrooler = self
        present(loginController, animated: true, completion: nil)
    }

  
}
