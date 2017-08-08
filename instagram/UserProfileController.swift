//
//  UserProfileController.swift
//  instagram
//
//  Created by Luiz Hammerli on 11/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let headerCellId = "headerCellId"
    let cellId = "cellId"
    var user: User?
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        setUpLogOutButton()
        registerCells()
        fetchUserData()        
    }
    
    func registerCells(){
        self.collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerCellId)
        self.collectionView?.register(UserProfileCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setUpLogOutButton(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogOutButton))
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        
    }
    
    func handleLogOutButton(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: UIAlertActionStyle.destructive, handler: {(_) in
        
            try? Firebase.Auth.auth().signOut()
            let loginController = LoginController()
            let navController = UINavigationController(rootViewController: loginController)
            self.present(navController, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func fetchOrderedPosts(){
        guard let user = user else{return}
        
        Firebase.Database.database().reference().child("post").child(user.id).queryOrdered(byChild: "date").observe(DataEventType.childAdded, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else {return}
            guard let user = self.user else {return}
            
            let post = Post(user, dic: dict)
            self.posts.insert(post, at: 0)
            
            self.collectionView?.reloadData()
            
        }) { (error) in
            
            print("Error")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellId, for: indexPath) as! UserProfileHeader
        header.user = self.user
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 200)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    fileprivate func fetchUserData(){
        
        let id = user?.id ?? Firebase.Auth.auth().currentUser?.uid
        guard let userId = id else {return}
        
        Firebase.Database.fetchUserWithUID(uid: userId) { (user) in
            DispatchQueue.main.async {
                self.user = user
                self.navigationItem.title = self.user?.name
                self.collectionView?.reloadData()
                self.fetchOrderedPosts()
            }
        }
    }
}
