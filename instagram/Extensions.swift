//
//  Extensions.swift
//  instagram
//
//  Created by Luiz Hammerli on 03/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

extension UIColor{

    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat)->UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension Database{
    
    static func fetchUserWithUID(uid: String, completition: @escaping (_ user: User)->()){
        
        Firebase.Database.database().reference().child("user").child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else {return}
            
            guard let name =  dict["name"] as? String else {return}
            guard let image =  dict["profileImageUrl"] as? String else {return}
            
            let user = User(id: uid, name: name, profileImageUrl: image)
            completition(user)
        })
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
}
