//
//  HomeCell.swift
//  instagram
//
//  Created by Luiz Hammerli on 09/07/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit

protocol CommentViewControllerDelegate {
    func goToCommentViewController(post: Post)->Void
    func didLike(cell: HomeCell)->Void
}

class HomeCell: UICollectionViewCell {
    
    var delegate:CommentViewControllerDelegate?
    
    var post: Post?{
        didSet{
            guard let imageUrl = post?.imageUrl else {return}
            guard let user = post?.user else {return}
            guard let url = URL(string: imageUrl) else {return}
            guard let profileImageUrl = URL(string: user.profileImageUrl) else {return}
            
            photoImageView.loadImageView(url)
            userProfileImageView.loadImageView(profileImageUrl)
            userNameLabel.text = user.name
            setUpcaption()
            
            post?.isLiked == true ? likeButton.setImage(#imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal), for: .normal) : likeButton.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40/2
        return iv
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let userNameLabel: UILabel = {
    
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionButton: UIButton = {
    
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    
    lazy var likeButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleLike), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    
    lazy var commentButton: UIButton = {
    
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(showCommentViewController), for: .touchUpInside)
        return button
    }()
    
    
    let sendButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    
    let ribbonButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    let comentLabel: UILabel = {
    
        let label = UILabel()
        label.numberOfLines = 0
        
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
        self.addSubview(photoImageView)
        self.addSubview(userProfileImageView)
        self.addSubview(userNameLabel)
        self.addSubview(optionButton)
        self.addSubview(comentLabel)
        
        userProfileImageView.anchor(top: topAnchor, bottom: nil, right: nil, left: leftAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, height: 40, width: 40)
        
        optionButton.anchor(top: topAnchor, bottom: userProfileImageView.bottomAnchor, right: rightAnchor, left: nil, paddingTop: 8, paddingBottom: 0, paddingLeft: 0, paddingRight: -8, height: nil, width: 40)
        
        userNameLabel.anchor(top: topAnchor, bottom: userProfileImageView.bottomAnchor, right: optionButton.leftAnchor, left: userProfileImageView.rightAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 8, paddingRight: 8, height: nil, width: nil)
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, bottom: nil, right: rightAnchor, left: leftAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: nil, width: nil)
        
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        setUpButtons()
        
        comentLabel.anchor(top: nil, bottom: bottomAnchor, right: rightAnchor, left: leftAnchor , paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: -8, height: 60, width: nil)
        
    }
    
    func setUpButtons(){
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendButton])
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        self.addSubview(ribbonButton)
        
        stackView.anchor(top: photoImageView.bottomAnchor, bottom: nil, right: nil, left: leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 4, paddingRight: 0, height: 50, width: 120)
        
        ribbonButton.anchor(top: photoImageView.bottomAnchor, bottom: nil, right: rightAnchor, left: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: -4, height: 50, width: 40)
    }
    
    func setUpcaption(){
    
        guard let post =  post else {return}
        
        let atributtedText = NSMutableAttributedString(string: post.user.name + "  ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        atributtedText.append(NSAttributedString(string: post.caption, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)]))
        
        atributtedText.append(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 4)]))
        
        atributtedText.append(NSAttributedString(string: post.time.timeAgoDisplay(), attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.gray]))
        
        comentLabel.attributedText = atributtedText
    }
    
    func showCommentViewController(){
        guard let post = self.post else {return}
        delegate?.goToCommentViewController(post: post)
    }
    
    func handleLike(){
        delegate?.didLike(cell: self)
    }
}
