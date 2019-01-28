//
//  NewMessageController.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/4.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController:UITableViewController{
 
    
    fileprivate let cellId = "cellId"
    
    var messageController:MessagesViewController?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupView()
        fetchUser()
    }
    
    fileprivate func fetchUser(){
        
        Database.database().reference().child("User").observe(.childAdded, with: { (snaps) in
            
            guard let snap = snaps.value as? [String:Any] else {return}
            let user = User(snap)
                user.uid = snaps.key
            self.users.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.dismiss(animated: true) {
            self.messageController?.showChatLogController(user)
        }
    }
    
    fileprivate func setupView(){
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    fileprivate func setupNavigationItem(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handldDismiss))
    }
    
    @objc fileprivate func handldDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.portrait.setupImageCacheWithURl(user.profileImageUrl ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}// end of the class

