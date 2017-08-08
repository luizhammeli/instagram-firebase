//
//  SharePhotoController.swift
//  instagram
//
//  Created by Luiz Hammerli on 25/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage:UIImage?
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    let selectedPhotoImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        setUpNavigationBat()
        setUpViews()
    }
    
    func setUpNavigationBat(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleShare))
    }
    
    func handleShare(){
        let imageId = NSUUID().uuidString
        guard let image = selectedImage else {return}
        guard let imgData = UIImageJPEGRepresentation(image, 0.3) else {return}
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        Firebase.Storage.storage().reference().child("posts").child(imageId).putData(imgData, metadata: nil) { (data, err) in
            
            if(err != nil){
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print("error")
            }
            guard let imageUrl = data?.downloadURL()?.absoluteString else {return}
            self.saveToDatabaseWithImageUrl(imageUrl)
        }
    }
    
    func setUpViews(){
        view.addSubview(containerView)
        containerView.anchor(top: self.topLayoutGuide.bottomAnchor, bottom: nil, right: self.view.rightAnchor, left: self.view.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 100, width: nil)
        
        containerView.addSubview(selectedPhotoImageView)
        containerView.addSubview(textView)
        
        selectedPhotoImageView.anchor(top: self.containerView.topAnchor, bottom: self.containerView.bottomAnchor, right: nil, left: self.containerView.leftAnchor, paddingTop: 8, paddingBottom: 8, paddingLeft: 8, paddingRight: 0, height: nil, width: 84)
        
        textView.anchor(top: self.selectedPhotoImageView.topAnchor, bottom: self.selectedPhotoImageView.bottomAnchor, right: self.view.rightAnchor, left: self.selectedPhotoImageView.rightAnchor, paddingTop: 0, paddingBottom: 8, paddingLeft: 8, paddingRight: -8, height: nil, width: nil)
        
        selectedPhotoImageView.image = selectedImage
    }
    
    func saveToDatabaseWithImageUrl(_ imageUrl:String){
        guard let userID = Firebase.Auth.auth().currentUser?.uid else {return}
        let time = Date().timeIntervalSince1970
        guard let caption = self.textView.text else {return}
        
        let values = ["imageUrl": imageUrl,"caption": caption as Any,"date": time, "width": self.selectedImage?.size.width as Any, "height": self.selectedImage?.size.height as Any] as [String: Any]
        
        Firebase.Database.database().reference().child("post").child(userID).childByAutoId().updateChildValues(values, withCompletionBlock: {(error, reference) in
            if error != nil{
                print("Error")
            }
            else{
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
            }
        })
    }
}
