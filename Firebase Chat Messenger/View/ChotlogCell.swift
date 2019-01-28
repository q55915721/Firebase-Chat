//
//  ChotlogCell.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/16.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import AVKit

class ChotlogCell:UICollectionViewCell{
    
    
    var message:Message?
    var chatLogController:ChatLogController?
    
    let textView:UITextView = {
        
        let tv = UITextView()
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.font = UIFont.systemFont(ofSize: 16)
            tv.isEditable = false
            tv.backgroundColor = .clear
            tv.textColor = .white
        return tv
    }()
    
    lazy var playBtn:UIButton = {
        
        let playbtn = UIButton(type: .system)
            playbtn.translatesAutoresizingMaskIntoConstraints = false
            playbtn.setImage(UIImage(named: "play"), for: .normal)
        playbtn.addTarget(self, action: #selector(handlePlay), for:.touchUpInside)
        playbtn.tintColor = .white
        return playbtn
    }()
    
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    
    let activiteIndecator:UIActivityIndicatorView = {
        let ac = UIActivityIndicatorView(style: .whiteLarge)
            ac.hidesWhenStopped = true
            ac.translatesAutoresizingMaskIntoConstraints = false
        return ac
    }()
    
    
    @objc fileprivate func handlePlay(){
        guard let url = URL(string: message?.videoUrl ?? "" ) else {return}
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubble.bounds
        bubble.layer.addSublayer(playerLayer!)
        
        player?.play()
        playBtn.isHidden = true
        activiteIndecator.startAnimating()
         print("Attempting to play video......???")
    }
    
    override func prepareForReuse() {
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activiteIndecator.stopAnimating()
    }
    
    
    let profileImageView:UIImageView = {
        
        let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.layer.cornerRadius = 16
            iv.clipsToBounds = true
            iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubble:UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ChotlogCell.blueColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
        
    }()
    
    lazy var imageMessage:UIImageView = {
        let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.contentMode = .scaleAspectFill
            iv.layer.cornerRadius = 16
            iv.clipsToBounds = true
            iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowZoom)))
        return iv
    }()
    
    @objc fileprivate func handleShowZoom(_ gesture:UITapGestureRecognizer){
    
        if message?.videoUrl != nil {
            return
        }
        
        if let imageView = gesture.view as? UIImageView {
            
            chatLogController?.showZoom(imageView)
        }
        
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupbubble()
        observe()
        
    }
    
    func observe(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name("viewWillDismissal"), object: nil, queue: .main) { (notification) in
            self.player?.pause()
        }
    }
    
    
    var bubbleWidConstraint:NSLayoutConstraint?
    var bubbleLeftAnchor:NSLayoutConstraint?
    var bubbleRightAnchor:NSLayoutConstraint?
    
    fileprivate func setupbubble(){
        addSubview(bubble)
        addSubview(textView)
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor,constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        bubble.topAnchor.constraint(equalTo: topAnchor).isActive = true
       bubbleRightAnchor = bubble.rightAnchor.constraint(equalTo: rightAnchor,constant: -8)
        bubbleRightAnchor?.isActive = true
        
        bubbleLeftAnchor = bubble.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleWidConstraint = bubble.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidConstraint?.isActive = true
        bubble.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
       
        textView.leftAnchor.constraint(equalTo: bubble.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubble.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubble.addSubview(imageMessage)
        
        imageMessage.topAnchor.constraint(equalTo: bubble.topAnchor).isActive = true
        imageMessage.leftAnchor.constraint(equalTo: bubble.leftAnchor).isActive = true
        imageMessage.heightAnchor.constraint(equalTo: bubble.heightAnchor).isActive = true
        imageMessage.widthAnchor.constraint(equalTo: bubble.widthAnchor).isActive = true
        
        bubble.addSubview(activiteIndecator)
        
        activiteIndecator.centerXAnchor.constraint(equalTo: bubble.centerXAnchor).isActive = true
        activiteIndecator.centerYAnchor.constraint(equalTo: bubble.centerYAnchor).isActive = true
        activiteIndecator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activiteIndecator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        bubble.addSubview(playBtn)
        playBtn.centerXAnchor.constraint(equalTo: bubble.centerXAnchor).isActive = true
        playBtn.centerYAnchor.constraint(equalTo: bubble.centerYAnchor).isActive = true
        playBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bringSubviewToFront(playBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
