//
//  PhotoCell.swift
//  instagram
//
//  Created by Luiz Hammerli on 18/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
    
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.white
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    func setUpViews(){
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, left: leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, height: nil, width: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
