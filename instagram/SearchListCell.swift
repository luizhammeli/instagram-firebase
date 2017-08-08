//
//  SearchListCell.swift
//  instagram
//
//  Created by Luiz Hammerli on 06/08/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit

class SearchListCell: UICollectionViewCell{
    
    var user: User? {
        didSet{
            guard let strUrl = user?.profileImageUrl else{return}
            guard let url = URL(string: (strUrl)) else {return}
            profileImageView.loadImageView(url)
            nameLabel.text = user?.name
        }
    }
    
    let profileImageView: CustomImageView = {
        
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50/2
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
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
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(separator)
        
        profileImageView.anchor(top: nil, bottom: nil, right: nil, left: leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, height: 50, width: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        nameLabel.anchor(top: profileImageView.topAnchor, bottom: nil, right: rightAnchor, left: profileImageView.rightAnchor, paddingTop: 10, paddingBottom: 0, paddingLeft: 8, paddingRight: 8, height: 15, width: nil)
        
        separator.anchor(top: nil, bottom: bottomAnchor, right: rightAnchor, left: nameLabel.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: 0.5, width: nil)
    }
}
