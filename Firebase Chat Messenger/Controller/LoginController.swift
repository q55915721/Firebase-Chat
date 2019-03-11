//
//  LoginController.swift
//  Firebase Chat Messenger
//
//  Created by 洪森達 on 2018/11/1.
//  Copyright © 2018 洪森達. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

   
    
    var messageCOntrooler:MessagesViewController?
    
    let inputContainer:UIView = {
        let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 5
            view.clipsToBounds = true
        return view
    }()
    
    let loginButton:UIButton = {
        
        let bt = UIButton()
        bt.setTitle("Register", for: .normal)
        bt.setTitleColor(.white, for: UIControl.State.normal)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        bt.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        bt.addTarget(self, action: #selector(handleLoginRegi), for: .touchUpInside)
        return bt
    }()
    
    @objc fileprivate func handleLoginRegi(){
        if loninRegisterSegmentedController.selectedSegmentIndex == 0 {
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    fileprivate func handleLogin(){
        guard let email = emailLabel.text, let password = passwordsLabel.text else {
            print("form isn't valid.")
            return}
        Auth.auth().signIn(withEmail: email, password: password) { (firUser, error) in
            if let err = error {
                print("error in signIn",err)
                return
            }
            
            print("Sign in successfully...")
            self.messageCOntrooler?.setupNavigationTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    lazy var loninRegisterSegmentedController:UISegmentedControl = {
        
        let sg = UISegmentedControl(items: ["Login","Register"])
            sg.tintColor = .purple
            sg.translatesAutoresizingMaskIntoConstraints = false
            sg.selectedSegmentIndex = 1
            sg.addTarget(self, action: #selector(handleLoginRegister), for: .valueChanged)
        
        return sg
    }()
    @objc fileprivate func handleLoginRegister(){
        let title = loninRegisterSegmentedController.titleForSegment(at: loninRegisterSegmentedController.selectedSegmentIndex)
        loginButton.setTitle(title, for: .normal)
        contianerHeightAnchor?.constant = loninRegisterSegmentedController.selectedSegmentIndex == 0 ? 100:150
        
        nameHeightAnchor?.isActive = false
        nameHeightAnchor = nameLabel.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: loninRegisterSegmentedController.selectedSegmentIndex == 0 ? 0:1/3)
        nameHeightAnchor?.isActive = true
        
        emailHeightAnchor?.isActive = false
        emailHeightAnchor = emailLabel.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: loninRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2:1/3)
        emailHeightAnchor?.isActive = true
        
        passwordHegihtsAnchor?.isActive = false
        passwordHegihtsAnchor = passwordsLabel.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: loninRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2:1/3)
        passwordHegihtsAnchor?.isActive = true
    }
    
    fileprivate let dataUrl = "https://gameofchat-5e2c6.firebaseio.com/"
    

    let nameLabel:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let nameSeparatorView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return view
    }()
    
    let emailLabel:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let emailSeparatorView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return view
    }()
    let passwordsLabel:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Passwords"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageProfile)))
        return imageView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDis)))
        view.addSubview(profileImageView)
        view.addSubview(inputContainer)
        view.addSubview(loginButton)
        view.addSubview(loninRegisterSegmentedController)
        addObserverKeyBoard()
        setupInputContainerView()
        setupRegisterBt()
        setupSegmented()
        setupProfileImageView()
    }
    @objc func handleDis(){
        view.endEditing(true)
    }
    fileprivate func addObserverKeyBoard(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoaed), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc fileprivate func handleKeyBoaed(_ notification: Notification){
        guard let userInfo = notification.userInfo else {return}
        
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let currentFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let target = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let dalta = target.origin.y - currentFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.view.frame.origin.y += dalta
        })
    }
    
    
    fileprivate func setupSegmented(){
        loninRegisterSegmentedController.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -12).isActive = true
        loninRegisterSegmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loninRegisterSegmentedController.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        loninRegisterSegmentedController.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
    fileprivate func setupProfileImageView(){
        
        profileImageView.bottomAnchor.constraint(equalTo: loninRegisterSegmentedController.topAnchor, constant: -12).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    fileprivate func setupRegisterBt(){
        loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 8).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    var nameHeightAnchor:NSLayoutConstraint?
    var emailHeightAnchor:NSLayoutConstraint?
    var passwordHegihtsAnchor:NSLayoutConstraint?
    var contianerHeightAnchor:NSLayoutConstraint?
    
    fileprivate func setupInputContainerView(){
        inputContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor , constant: 130).isActive = true
        inputContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
       
        
           contianerHeightAnchor = inputContainer.heightAnchor.constraint(equalToConstant: 150)
           contianerHeightAnchor?.isActive = true
        
        inputContainer.addSubview(nameLabel)
        inputContainer.addSubview(nameSeparatorView)
        inputContainer.addSubview(emailLabel)
        inputContainer.addSubview(emailSeparatorView)
        inputContainer.addSubview(passwordsLabel)
        
        nameLabel.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 12).isActive = true
        nameLabel.topAnchor.constraint(equalTo: inputContainer.topAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        nameHeightAnchor = nameLabel.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        nameHeightAnchor?.isActive = true
        
        nameSeparatorView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainer.leftAnchor).isActive = true
        
        
        
        emailLabel.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 12).isActive = true
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
       emailHeightAnchor = emailLabel.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        emailHeightAnchor?.isActive = true
        
        emailSeparatorView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainer.leftAnchor).isActive = true
        
        
        
        passwordsLabel.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 12).isActive = true
        passwordsLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        passwordsLabel.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        passwordHegihtsAnchor =  passwordsLabel.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        passwordHegihtsAnchor?.isActive = true
        
        
        
        
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }

    
    
    

}

extension UIColor {
    
    convenience init(r:CGFloat,g:CGFloat,b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
