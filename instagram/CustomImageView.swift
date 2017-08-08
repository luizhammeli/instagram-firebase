//
//  CustomImageView.swift
//  instagram
//
//  Created by Luiz Hammerli on 09/07/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    var lastUrlLoaded:String?
    var cachedImages = [String: UIImage]()
    
    func loadImageView(_ imageUrl: URL){
        
        if let image = cachedImages[imageUrl.absoluteString]{
            self.image = image
            return
        }
        
        lastUrlLoaded = imageUrl.absoluteString
        URLSession.shared.dataTask(with: imageUrl) { (data, response, err) in
            if err != nil{
                return
            }
            
            guard let imageData = data else {return}
            guard let image = UIImage(data: imageData) else {return}
            
            if (imageUrl.absoluteString != self.lastUrlLoaded){
                return
            }
            
            self.cachedImages[imageUrl.absoluteString] = image
            
            DispatchQueue.main.async {
                self.image = image
            }
            
        }.resume()
    }
}
