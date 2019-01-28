//
//  ChatLogController.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/7.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
class ChatLogController:UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
   lazy var textField:UITextField = {
        let tf = UITextField()
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.delegate = self
            tf.placeholder = "Say something!"
    
    
        return tf
    }()
    
    var user:User!{
        didSet{
            navigationItem.title = user.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    fileprivate func setupView(){
        
        
        collectionView.backgroundColor = .white
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.register(ChotlogCell.self, forCellWithReuseIdentifier: cellid)
        
    }
    
    fileprivate func observeMessages(){
        guard let toid = user.uid else {return}
         Database.database().reference().child("User-Messages").child(User.currentUser()).child(toid).observe(.childAdded, with: { (snapshot) in
            let messageid = snapshot.key
            
            Database.database().reference().child("Messages").child(messageid).observe(.value, with: { (snapshot) in
                guard let snap = snapshot.value as? [String:Any] else {return}
                let message = Message(snap)
                self.messages.append(message)
               
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
                }
            })
            
            
        }, withCancel: nil)
        
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    fileprivate let cellid = "cellid"
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! ChotlogCell
        let message = messages[indexPath.item]
        cell.message = message
        cell.chatLogController = self
        print(message)
        cell.textView.text = message.text
        if let text = message.text {
            cell.bubbleWidConstraint?.constant = measureHeightWith(text).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil {
            cell.bubbleWidConstraint?.constant = 200
            cell.textView.isHidden = true
        }
        setupCell(cell, message: message)
        
        return cell
    }
    
    
    
    fileprivate func setupCell(_ cell:ChotlogCell,message:Message){
        
        
        if let profileImg = user.profileImageUrl {
            
            cell.profileImageView.setupImageCacheWithURl(profileImg)
        }
        
        if message.fromId == User.currentUser() {
            //outcoming
            
            cell.profileImageView.isHidden = true
            cell.bubble.backgroundColor = ChotlogCell.blueColor
            cell.textView.textColor = .white
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
           
        }else{
            //incoming
            
            cell.profileImageView.isHidden = false
            cell.bubble.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if  message.videoUrl != nil {
            cell.playBtn.isHidden = false
        }else{
            cell.playBtn.isHidden = true
        }
        
        
        if let imageurl = message.imageUrl {
            print(imageurl)
            cell.imageMessage.setupImageCacheWithURl(imageurl)
            cell.bubble.backgroundColor = .clear
            cell.imageMessage.isHidden = false
            
        }else{
            
            cell.imageMessage.isHidden = true
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        let width = UIScreen.main.bounds.width
        let message = messages[indexPath.item]
        if let text = message.text {
            height = measureHeightWith(text).height + 20
        }else if let imageW = message.imageWidth?.floatValue ,let imageH = message.imageHeight?.floatValue {
            height = CGFloat(imageH / imageW * 200)
        }
        return CGSize(width: width, height: height)
    }
    
    fileprivate func measureHeightWith(_ text:String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        return NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    lazy var container: UIView = {

        return self.setupInputVIew()
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return container
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    fileprivate func setupInputVIew() -> UIView {
        
        let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
            container.backgroundColor = .white
        
        let bt = UIButton(type: .system)
            bt.translatesAutoresizingMaskIntoConstraints = false
            bt.setTitle("Send", for: .normal)
        bt.addTarget(self, action: #selector(handleSendBt), for: .touchUpInside)
        container.addSubview(bt)
        
        let uploadImage = UIImageView()
            uploadImage.translatesAutoresizingMaskIntoConstraints = false
            uploadImage.image = UIImage(named: "upload_image_icon")
            uploadImage.isUserInteractionEnabled = true
        uploadImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUpload)))
        container.addSubview(uploadImage)
        
        uploadImage.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        uploadImage.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        uploadImage.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImage.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
        
        
        bt.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        bt.widthAnchor.constraint(equalToConstant: 80).isActive = true
        bt.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
        bt.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        container.addSubview(textField)
        
        textField.leftAnchor.constraint(equalTo: uploadImage.rightAnchor, constant: 8).isActive = true
        textField.rightAnchor.constraint(equalTo: bt.leftAnchor,constant:-8).isActive = true
        textField.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
        
        
        let separatorLine = UIView()
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            separatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        container.addSubview(separatorLine)
        
        separatorLine.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: container.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        
        return container
    }
    
   @objc fileprivate func handleUpload(){
        let imgPicker = UIImagePickerController()
            imgPicker.allowsEditing = true
            imgPicker.delegate = self
            imgPicker.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleSelectedVideoUrl(videoUrl)
        }else{
            handlePickingImage(info)
        }
       
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func handleSelectedVideoUrl(_ videoUrl:URL){
        
        let fileName = UUID().uuidString + ".mov"
        
        let ref = Storage.storage().reference().child(User.currentUser()).child(fileName)
        let uploadTask = ref.putFile(from: videoUrl, metadata: nil) { (mate, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            ref.downloadURL(completion: { (url, error) in
                
                if let thumbnail = self.thumbnailImage(videoUrl) {
                  
                    guard let videoUrl = url?.absoluteString else {return}
                    
                    self.uploadImageToFireStorage(thumbnail, completion: { (imageUrl) in
                        
                        let properties = ["imageUrl":imageUrl,"imageHeight":thumbnail.size.height,"imageWidth":thumbnail.size.width,"videoUrl":videoUrl] as [String : Any]
                        
                        self.sendMessagesWithProperties(properties)
                    })
                }
                
                
            })
            
            
        }
        
        uploadTask.observe(.progress) { (snap) in
            
            guard let progress = snap.progress else {return}
            let persentage = Int(progress.fractionCompleted * 100)
            print(progress.fractionCompleted)
            self.navigationItem.title = String(persentage) + "%"
            
           
        }
        uploadTask.observe(.success) { (snap) in
            self.navigationItem.title = self.user.name
        }
      
    }
    
    fileprivate func thumbnailImage(_ url:URL)->UIImage?{
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        do{
            
            let image = try generator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            let thumbnail = UIImage(cgImage: image)
            return thumbnail
        }catch let error{
            print(error)
        }
        
        return nil
    }
    
    fileprivate func handlePickingImage(_ info:[UIImagePickerController.InfoKey:Any]){
        var selectedimage:UIImage?
        
        if let edited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedimage = edited
            
        }else if let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedimage = original
        }
        
        if let choosedImage = selectedimage {
            
            uploadImageToFireStorage(choosedImage) { (imageUrl) in
                
                let properties = ["imageUrl":imageUrl,"imageHeight":choosedImage.size.height,"imageWidth":choosedImage.size.width] as [String : Any]
                
                self.sendMessagesWithProperties(properties)
            }
        }
        
        
        
    }
    
    fileprivate func uploadImageToFireStorage(_ image:UIImage,completion:@escaping(_ imageUrl:String)->Void){
        
        let fileName = UUID().uuidString + ".Jpg"
        let ref = Storage.storage().reference().child(User.currentUser()).child(fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            ref.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let urlString = url?.absoluteString else {return}
                completion(urlString)
                
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       
     dismiss(animated: true, completion: nil)
    }
    
    fileprivate func sendMessagesWithProperties(_ properties:[String:Any]){
        
        let ref = Database.database().reference().child("Messages").childByAutoId()
        guard let fromId = Auth.auth().currentUser?.uid else {return}
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let toid = user.uid else {return}
        var values = ["FromId":fromId,"Timestamp":timestamp,"ToId":toid] as [String:Any]
        
        properties.forEach({values[$0] = $1})
        ref.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print("error in here",error!.localizedDescription)
            }
            
            self.textField.text = ""
            
            guard let messageID = ref.key else {return}
            let userMessage = Database.database().reference().child("User-Messages").child(fromId).child(toid).child(messageID)
            userMessage.setValue(1)
            
            let recipientMessage = Database.database().reference().child("User-Messages").child(toid).child(fromId).child(messageID)
            recipientMessage.setValue(1)
            
        }
        
    }
    
    @objc func handleSendBt(){
        
        print("11")
        if let text = textField.text {
            
            let properties = ["Text":text]
           sendMessagesWithProperties(properties)
        }

    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendBt()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "viewWillDismissal"), object: nil)
    }
    
    
    var originalImage:UIImageView?
    var originalFrame:CGRect?
    var background:UIView?
    func showZoom(_ originalImage:UIImageView ){
       
        self.originalImage = originalImage
        self.originalImage?.isHidden = true
        
        originalFrame = originalImage.convert(originalImage.frame, to: nil)
        
        let zoomImageView = UIImageView(frame: originalFrame!)
            zoomImageView.image = originalImage.image
            zoomImageView.isUserInteractionEnabled = true
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissZoom)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            background = UIView(frame: keyWindow.frame)
            background?.backgroundColor = .black
            background?.alpha = 0
            keyWindow.addSubview(background!)
           keyWindow.addSubview(zoomImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.background?.alpha = 1
                self.container.alpha = 0
                
                let height = self.originalFrame!.height / self.originalFrame!.width * keyWindow.frame.width
                
                zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomImageView.center = keyWindow.center

            })
        }
        
        
    }
    
    
    @objc fileprivate func handleDismissZoom(_ tapGesture:UITapGestureRecognizer){
        let zoomView = tapGesture.view
            zoomView?.layer.cornerRadius = 16
            zoomView?.clipsToBounds = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.background?.alpha = 0
            self.container.alpha = 1
            zoomView?.frame = self.originalFrame!
            
        }) { (completion:Bool) in
            
            zoomView?.removeFromSuperview()
            self.originalImage?.isHidden = false
        }
      
    }
    
    
    
    
}


