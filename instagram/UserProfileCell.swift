//
//  UserProfileCell.swift
//  instagram
//
//  Created by Luiz Hammerli on 08/07/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit

class UserProfileCell: UICollectionViewCell {
    
    var post: Post?{
        didSet{
            guard let imageUrl = post?.imageUrl else {return}
            guard let url = URL(string: imageUrl) else {return}
            imageView.loadImageView(url)
        }
    }        
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        addSubview(imageView)
        imageView.anchor(top: self.topAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, left: self.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: nil, width: nil)
    }
}
