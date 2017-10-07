//
//  File.swift
//  instagram
//
//  Created by Luiz Hammerli on 24/09/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import Foundation

struct Comment {
    
    var text: String
    //var creationDate
    var user:User
    
    init(dictionary: [String: Any], user:User) {
        text = dictionary["text"] as? String ?? ""
        self.user = user
    }
}
