//
//  User.swift
//  instagram
//
//  Created by Luiz Hammerli on 23/07/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import Foundation

struct User {
    var name: String
    var profileImageUrl: String
    var id: String
    
    init(id:String, name:String, profileImageUrl: String){
        
        self.id = id
        self.name = name
        self.profileImageUrl = profileImageUrl
    }
}
