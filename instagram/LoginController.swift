//
//  LoginController.swift
//  instagram
//
//  Created by Luiz Hammerli on 15/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoImageVIew: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Instagram_logo_white")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let logoContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        
        return view
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.rgb(red: 27, green: 156, blue: 226)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(showSignUpController), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        
        let tv = UITextField()
        tv.placeholder = "Email"
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.borderStyle = .roundedRect
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.keyboardType = .emailAddress
        tv.addTarget(self, action: #selector(handleTextField), for: UIControlEvents.editingChanged)
        tv.autocapitalizationType = .none
        return tv
    }()
    
    let passwordTextField: UITextField = {
        
        let tv = UITextField()
        tv.placeholder = "Password"
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.borderStyle = .roundedRect
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isSecureTextEntry = true
        tv.addTarget(self, action: #selector(handleTextField), for: UIControlEvents.editingChanged)
        return tv
    }()
    
    let signInButton:UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Login", for: UIControlState.normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.rgb(red: 145, green: 206, blue: 240)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignInButton), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setUpViews(){
        
        self.view.addSubview(signUpButton)
        self.view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageVIew)
        
        signUpButton.anchor(top: nil, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, left: self.view.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 50, width: nil)
        
        logoContainerView.anchor(top: self.view.topAnchor, bottom: nil, right: self.view.rightAnchor, left: self.view.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 150, width: nil)
        
        logoImageVIew.anchor(top: nil, bottom: nil, right: nil, left: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 50, width: 200)
        
        logoImageVIew.centerXAnchor.constraint(equalTo: self.logoContainerView.centerXAnchor).isActive = true
        
        logoImageVIew.centerYAnchor.constraint(equalTo: self.logoContainerView.centerYAnchor).isActive = true
        
        let viewStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signInButton])
        viewStack.distribution = .fillEqually
        viewStack.axis = .vertical
        viewStack.spacing = 10
        
        self.view.addSubview(viewStack)
        
        viewStack.anchor(top: logoContainerView.bottomAnchor, bottom: nil, right: self.view.rightAnchor, left: self.view.leftAnchor, paddingTop:  40, paddingBottom: 0, paddingLeft: 50, paddingRight: -40, height: 140, width: nil)
    }
    
    func showSignUpController(){
        self.navigationController?.pushViewController(SignUpController(), animated: true)
    }
    
    func handleTextField(){

        let isFormValid = emailTextField.text?.characters.count ?? 0 > 0 && passwordTextField.text?.characters.count ?? 0 > 0
        
        if isFormValid{
            signInButton.isEnabled = true
            signInButton.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
            return
        }
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = UIColor.rgb(red: 145, green: 206, blue: 240)
        return
    }
    
    func handleSignInButton(){
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            
            if(err != nil){                
                print("Erro")
                return
            }
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            
            mainTabBarController.setUpMainTabBarController()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
