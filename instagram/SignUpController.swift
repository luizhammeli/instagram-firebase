//
//  ViewController.swift
//  instagram
//
//  Created by Luiz Hammerli on 03/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    let userPhotoButton:UIButton = {
        
        let button = UIButton()        
        button.setImage(UIImage(named: "plus_photo"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
    
        let tv = UITextField()
        tv.placeholder = "Username"
        tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tv.borderStyle = .roundedRect
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.addTarget(self, action: #selector(handleTextField), for: UIControlEvents.editingChanged)
        tv.autocapitalizationType = .words
        return tv
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
    
    let signUpButton:UIButton = {
    
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: UIControlState.normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.rgb(red: 145, green: 206, blue: 240)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUpButton), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    func handlePlusPhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func handleSignUpButton(){
        
        guard let email = emailTextField.text else{return}
        guard let pass = passwordTextField.text else{return}
        guard let name = nameTextField.text else{return}
        
        Firebase.Auth.auth().createUser(withEmail: email, password: pass) { (user, err) in
            
            if err != nil{
                return
            }
            
            
            guard let image = self.userPhotoButton.imageView?.image else {return}
            
            guard let data = UIImageJPEGRepresentation(image, 0.3) else{return}
            
            let fileName = NSUUID().uuidString
            Firebase.Storage.storage().reference().child("user").child(fileName).putData(data, metadata: nil, completion: { (metaData, err) in
                
                if err != nil{
                    return
                }
                
                guard let imageUrl = metaData?.downloadURL()?.absoluteString else {return}
                
                let userData = ["name": name, "profileImageUrl": imageUrl]
                
                guard let id = user?.uid else{return}
                
                print("User: \(id)")
                let value = [id: userData]
                
                Firebase.Database.database().reference().child("user").updateChildValues(value, withCompletionBlock: { (err, data) in
                    
                    if err != nil{
                        return
                    }
                    
                    print("dados gravado")
                })
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            self.userPhotoButton.setImage(image.withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
            userPhotoButton.layer.cornerRadius = userPhotoButton.frame.width/2
            userPhotoButton.layer.masksToBounds = true
        }else if let image = info["UIImagePickerControllerEditedImage"] as? UIImage{
            self.userPhotoButton.setImage(image.withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        }
        
        userPhotoButton.layer.cornerRadius = userPhotoButton.frame.width/2
        userPhotoButton.layer.masksToBounds = true
        userPhotoButton.layer.borderColor = UIColor.black.cgColor
        userPhotoButton.layer.borderWidth = 3
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleTextField(){
        
        let formValid = nameTextField.text?.characters.count ?? 0 > 3 && emailTextField.text?.characters.count ?? 0 > 3 && passwordTextField.text?.characters.count ?? 0 > 3
        
        if formValid{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 27, green: 156, blue: 226)
        }else{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 145, green: 206, blue: 240)
        }
    }
    
    func setUpViews(){
        
        self.view.addSubview(userPhotoButton)
        
        userPhotoButton.anchor(top: self.view.topAnchor, bottom: nil, right: nil, left: nil, paddingTop: 40, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 140, width: 140)
        userPhotoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let viewStack = UIStackView(arrangedSubviews: [emailTextField, nameTextField, passwordTextField,signUpButton])
        self.view.addSubview(viewStack)
        viewStack.spacing = 10
        viewStack.distribution = .fillEqually
        viewStack.axis = .vertical
        viewStack.anchor(top: self.userPhotoButton.bottomAnchor, bottom: nil, right: self.view.rightAnchor, left: self.view.leftAnchor, paddingTop: 20, paddingBottom: 0, paddingLeft: 40, paddingRight: -40, height: 200, width: nil)
    }
}

extension UIView{

    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, left: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingBottom: CGFloat, paddingLeft: CGFloat, paddingRight: CGFloat, height: CGFloat?, width: CGFloat?){
 
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right{
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if let left = left{
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let height = height{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let width = width{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    
    }
}

