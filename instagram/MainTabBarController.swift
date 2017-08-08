//
//  MainTabBarController.swift
//  instagram
//
//  Created by Luiz Hammerli on 11/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.delegate = self
        
        if (Firebase.Auth.auth().currentUser == nil){
            
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)                
            }
            return
        }
        
        setUpMainTabBarController()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let selectedIndex = self.viewControllers?.index(of: viewController){
            if selectedIndex == 2{
                let layout = UICollectionViewFlowLayout()
                let collectionView = PhotoSelectorController(collectionViewLayout: layout)
                let navController = UINavigationController(rootViewController: collectionView)
                self.present(navController, animated: true, completion: nil)
                return false
            }else{
                return true
            }
        }else{
            return true
        }
    }
    
    func setUpMainTabBarController(){
    
        //Home Profile
        let homeNavController = templateNavController(selectedImage: #imageLiteral(resourceName: "home_selected"), unselectedImage: #imageLiteral(resourceName: "home_unselected"), viewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Plus Profile
        let plusNavController = templateNavController(selectedImage: #imageLiteral(resourceName: "plus_unselected"), unselectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        //Like Profile
        let likeNavController = templateNavController(selectedImage: #imageLiteral(resourceName: "like_selected"), unselectedImage: #imageLiteral(resourceName: "like_unselected"))
        
        //Search Profile
        let searchNavController = templateNavController(selectedImage: #imageLiteral(resourceName: "search_selected"), unselectedImage: #imageLiteral(resourceName: "search_unselected"), viewController: SearchViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //User Profile
        let userProfileNavController = templateNavController(selectedImage: #imageLiteral(resourceName: "profile_selected"), unselectedImage: #imageLiteral(resourceName: "profile_unselected"), viewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        tabBar.tintColor = .black
        
        self.viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController]
        
        guard let itens = tabBar.items else{return}
        
        for item in itens{
        
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0 )
        }
    }
    
    func templateNavController(selectedImage: UIImage, unselectedImage: UIImage, viewController: UIViewController = UIViewController())-> UINavigationController{
        
        let viewController = viewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.image = unselectedImage
        
        return navController
    }
}
