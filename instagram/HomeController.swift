//
//  HomeController.swift
//  instagram
//
//  Created by Luiz Hammerli on 09/07/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var posts = [Post]()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        addFeedNotification()
        setUpNavController()
        self.collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView?.backgroundColor = .white
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        self.collectionView?.refreshControl = refreshControl
        fetchPost()
    }
    
    func addFeedNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: SharePhotoController.updateFeedNotificationName, object: nil)
    }
    
    func handleRefresh(){
        self.posts.removeAll()
        fetchPost()
    }
    
    func fetchPost(){
        fetchCurrentUserPost()
        fetchFollowingUsersPost()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func setUpNavController(){
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 40 + 8 + 8
        height += self.view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    func fetchCurrentUserPost(){
        guard let userId = Firebase.Auth.auth().currentUser?.uid else {return}
            
        Firebase.Database.fetchUserWithUID(uid: userId) { (user) in
                self.fetchPostWithUser(user)
        }
    }
    
    func fetchFollowingUsersPost(){
        guard let userId = Firebase.Auth.auth().currentUser?.uid else {return}
        
        let ref = Firebase.Database.database().reference().child("Following").child(userId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else {return}
            
            dict.forEach({ (key, value) in
                Firebase.Database.fetchUserWithUID(uid: key) { (user) in
                    self.fetchPostWithUser(user)
                }
            })
        })
    }
    
    fileprivate func fetchPostWithUser(_ user: User){
            Firebase.Database.database().reference().child("post").child(user.id).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
                self.collectionView?.refreshControl?.endRefreshing()
                guard let dictionaries = snapshot.value as? [String: Any] else {return}
                dictionaries.forEach({ (key: String, value: Any) in
                    guard let dictionary = value as? [String: Any] else {return}
                
                    let post = Post(user, dic: dictionary)
                    self.posts.append(post)})
                
            self.posts.sort(by: { (p1, p2) -> Bool in
                p1.time.compare(p2.time) == .orderedDescending
            })
            
            self.collectionView?.reloadData()            
        })
    }
}
