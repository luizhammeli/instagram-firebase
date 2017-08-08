//
//  Post.swift
//  instagram
//
//  Created by Luiz Hammerli on 08/07/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import Foundation

struct Post{

    let imageUrl: String
    let user: User
    let caption: String
    let time: Date
    
    init(_ user:User, dic: [String: Any]){
        imageUrl = dic["imageUrl"] as? String ?? ""
        self.caption = dic["caption"] as? String ?? ""
        let secondsFrom1970 = dic["date"] as? Double ?? 0
        time = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.user = user        
    }
}
