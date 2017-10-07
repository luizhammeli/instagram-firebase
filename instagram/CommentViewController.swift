//
//  CommentViewController.swift
//  instagram
//
//  Created by Luiz Hammerli on 07/09/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var post:Post?
    let cellID = "cellID"
    var comments = [Comment]()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        view.addSubview(self.submitButton)
        self.submitButton.anchor(top: view.topAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, left: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: -12, height: 0, width: 50)
        self.submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        view.addSubview(self.textField)
        self.textField.anchor(top: view.topAnchor, bottom: view.bottomAnchor, right: self.submitButton.leftAnchor, left: view.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 12, paddingRight: 0, height: nil, width: nil)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        view.addSubview(separatorView)
        
        separatorView.anchor(top: view.topAnchor, bottom: nil, right: view.rightAnchor, left: view.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 0.5, width: nil)
        
        return view

    }()
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        return textField
    }()
    
    let submitButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = .white
        navigationItem.title = "Comments"
        self.collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellID)
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.textField.delegate = self
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView?{
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        
        if(indexPath.item == comments.count-1 && comments.count > 1){
            cell.separatorView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = CommentCell(frame: frame)
        cell.comment = comments[indexPath.item]
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = cell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    func handleSubmit(){
        guard let post = post else {return}
        guard let postID = post.id else {return}
        guard let text = textField.text else {return}
        disableTextField(true)
        
        let dic = ["creationDate": Date().timeIntervalSince1970, "id": post.user.id, "text": text] as[String : Any]
        
        Firebase.Database.database().reference().child("comments").child(postID).childByAutoId().updateChildValues(dic)
        textField.text?.removeAll()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //self.view.endEditing(true)
    }
    
    func fetchComments(){
        guard let postID = post?.id else {return}
        
        Firebase.Database.database().reference().child("comments").child(postID).observe(.childAdded, with: { (snapshot) in
            
            guard let dic = snapshot.value as? [String: Any] else {return}
            guard let uid = dic["id"] as? String else {return}
            
            Firebase.Database.fetchUserWithUID(uid: uid, completition: { (user) in
                let comment = Comment(dictionary: dic, user: user)
                self.comments.append(comment)
                self.collectionView?.reloadData()
            })
            
        }) { (error) in
            print("error")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {return}
        
        if(text.isEmpty){
            disableTextField(true)
        }else{
            disableTextField(false)
        }
    }
    
    func disableTextField(_ disable:Bool = false){
        if(disable){
            submitButton.isEnabled = false
            submitButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        }else{
            submitButton.isEnabled = true
            submitButton.setTitleColor(UIColor.rgb(red: 0, green: 120, blue: 248), for: .normal)
        }
    }
}
