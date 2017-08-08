//
//  UserProfileHeader.swift
//  instagram
//
//  Created by Luiz Hammerli on 11/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {        
    
    var user:User?{
    
        didSet{
            if let name = user?.name{
                nameLabel.text = name
            }
            
            guard let profileImageUrl = user?.profileImageUrl else {return}
            guard let imageUrl = URL(string: profileImageUrl) else {return}
            profileImageView.loadImageView(imageUrl)
            setUpFollowButton()
        }
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 80 / 2
        imageView.layer.masksToBounds = true
        
        return imageView
    }()

    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleEditButton), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let listButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return button
    }()
    
    let markbookButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return button
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        //label.text = " "
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    let postLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()

    let followersLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        self.addSubview(profileImageView)
        self.addSubview(nameLabel)
        self.addSubview(editProfileFollowButton)
        
        profileImageView.anchor(top: self.topAnchor, bottom: nil, right: nil, left: self.leftAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 12, paddingRight: 0, height: 80, width: 80)
        
        nameLabel.anchor(top: profileImageView.bottomAnchor, bottom: nil, right: rightAnchor, left: leftAnchor, paddingTop: 14, paddingBottom: 0, paddingLeft: 20, paddingRight: 0, height: 30, width: nil)
        
        setUpBottomToolbar()
        setUpUserStatsView()
        
        editProfileFollowButton.anchor(top: postLabel.bottomAnchor, bottom: nil, right: followingLabel.rightAnchor, left: postLabel.leftAnchor, paddingTop: 2, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 34, width: nil)
    }
    
    func setUpUserStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        
        self.addSubview(stackView)
        stackView.anchor(top: topAnchor, bottom: nil, right: rightAnchor, left: profileImageView.rightAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 12, paddingRight: -14, height: 50, width: nil)
    }
    
    func setUpFollowButton(){
        guard let currentUserId = Firebase.Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.id else {return}
        
        if (currentUserId == userId){
            return
        }
        
        Firebase.Database.database().reference().child("Following").child(currentUserId).child(userId).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if let isFollowing = snapshot.value as? Int, isFollowing == 1{
                self.setUpEditButtonStyleToUnfollow()
            }else{
                self.setUpEditButtonStyleToFollow()
            }
        })                
    }
    
    func setUpBottomToolbar(){
    
        let topDividerLine = UIView()
        topDividerLine.backgroundColor = UIColor.lightGray
        
        let bottomDividerLine = UIView()
        bottomDividerLine.backgroundColor = UIColor.lightGray
        
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, markbookButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerLine)
        addSubview(bottomDividerLine)
        
        stackView.anchor(top: nil, bottom: self.bottomAnchor, right: self.rightAnchor, left: self.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 50, width: 0)
        
        topDividerLine.anchor(top: stackView.topAnchor, bottom: nil, right: self.rightAnchor, left: self.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 1, width: 0)
        
        bottomDividerLine.anchor(top: stackView.bottomAnchor, bottom: nil, right: self.rightAnchor, left: self.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 1, width: 0)
    }
    
    fileprivate func loadProfileImage(_ imageUrl: URL){
        
        URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, err) in
            if err != nil{
                return
            }
            
            guard let imageData = data else {return}
            guard let image = UIImage(data: imageData) else {return}
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
            
        }).resume()
    }
    
    func handleEditButton(){
        
        guard let currentLoggedUserId = Firebase.Auth.auth().currentUser?.uid else {return}
        guard let followUserId = user?.id else {return}
        let value = [followUserId: 1]
        let ref = Firebase.Database.database().reference().child("Following").child(currentLoggedUserId)
        
        if(editProfileFollowButton.titleLabel?.text == "Follow"){
            ref.updateChildValues(value) { (err, ref) in
                if let error = err {
                    print(error)
                    return
                }
                self.setUpEditButtonStyleToUnfollow()
            }
        }else if(editProfileFollowButton.titleLabel?.text == "Unfollow"){
            ref.child(followUserId)
            ref.removeValue(completionBlock: { (err, ref) in
                if let error = err {
                    print(error)
                    return
                }
                
                print("User removed")
                self.setUpEditButtonStyleToFollow()
            })
        }
        print("1")
    }
    
    func setUpEditButtonStyleToFollow(){
        editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        editProfileFollowButton.setTitle("Follow", for: .normal)
        editProfileFollowButton.layer.borderColor = UIColor.black.cgColor
        editProfileFollowButton.layer.borderWidth = 0.4
        editProfileFollowButton.setTitleColor(.white, for: .normal)
    }
    
    func setUpEditButtonStyleToUnfollow(){
        editProfileFollowButton.setTitle("Unfollow", for: .normal)
        editProfileFollowButton.layer.borderColor = UIColor.black.cgColor
        editProfileFollowButton.layer.borderWidth = 0.4
        editProfileFollowButton.setTitleColor(.black, for: .normal)
        editProfileFollowButton.backgroundColor = .white
    }
}
