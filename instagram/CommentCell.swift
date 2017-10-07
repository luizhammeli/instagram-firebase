//
//  CommentCell.swift
//  instagram
//
//  Created by Luiz Hammerli on 24/09/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet{
            guard let comment = comment else {return}
            textView.text = comment.text
            let atributtedText = NSMutableAttributedString(string: comment.user.name, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
            atributtedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)]))
            textView.attributedText = atributtedText
            guard let url = URL(string: comment.user.profileImageUrl) else {return}
            userImageView.loadImageView(url)
        }
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    let userImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40/2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        self.addSubview(textView)
        self.addSubview(userImageView)
        self.addSubview(separatorView)
        
        userImageView.anchor(top: self.topAnchor, bottom: nil, right: nil, left: self.leftAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 4, paddingRight: 0, height: 40, width: 40)
        
        textView.anchor(top: self.topAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, left: userImageView.rightAnchor, paddingTop: 2, paddingBottom: 4, paddingLeft: 4, paddingRight: -5, height: nil, width: nil)
        
        separatorView.anchor(top: nil, bottom: self.bottomAnchor, right: self.rightAnchor, left: textView.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 5, paddingRight: 0, height: 0.5, width: nil)
    }
}
