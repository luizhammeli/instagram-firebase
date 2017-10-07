//
//  UserProfileController.swift
//  instagram
//
//  Created by Luiz Hammerli on 11/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileControllerProtocol {
    
    let headerCellId = "headerCellId"
    let cellId = "cellId"
    let listCellId = "listCellId"
    var user: User?
    var posts = [Post]()
    var isGridViewSelected = true
    var isFinished = false
    
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
        self.collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: listCellId)
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
    
    fileprivate func paginatePosts(){
        guard let uid = user?.id else {return}
        let ref = Firebase.Database.database().reference().child("post").child(uid)
        //var query = ref.queryOrderedByKey()
        var query = ref.queryOrdered(byChild: "date")
        guard let user = self.user else{return}
        
        if(posts.count > 0){
            let value = posts.last?.time.timeIntervalSince1970
            //let value = posts.last?.id
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            if (allObjects.count < 4){
                self.isFinished = true
            }
            if(self.posts.count > 0 && allObjects.count > 0){
                allObjects.removeLast()
            }
            
            allObjects.reverse()
                        
            allObjects.forEach({ (snapshot) in
                guard let dic = snapshot.value as? [String: Any] else {return}
                var post = Post(user, dic: dic)
                post.id = snapshot.key
                self.posts.append(post)
            })
            
            self.posts.forEach({ (post) in
                print(post.id ?? "")
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Error")
        }
        
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
        header.delegate = self
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.item == posts.count - 1 && !isFinished){
            paginatePosts()
        }
        
        if(isGridViewSelected){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCell
            cell.post = posts[indexPath.item]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellId, for: indexPath) as! HomeCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(isGridViewSelected){
            let width = (self.view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }else{
            var height:CGFloat = 40 + 8 + 8
            height += self.view.frame.width
            height += 50
            height += 60
            
            return CGSize(width: self.view.frame.width, height: height)
        }
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
    
    func girdViewSelected(){
        isGridViewSelected = true
        self.collectionView?.reloadData()
    }
    
    func listViewSelected(){
        isGridViewSelected = false
        self.collectionView?.reloadData()
    }
    
    fileprivate func fetchUserData(){
        
        let id = user?.id ?? Firebase.Auth.auth().currentUser?.uid
        guard let userId = id else {return}
        
        Firebase.Database.fetchUserWithUID(uid: userId) { (user) in
            DispatchQueue.main.async {
                self.user = user
                self.navigationItem.title = self.user?.name
                self.collectionView?.reloadData()
                self.paginatePosts()
                //self.fetchOrderedPosts()
            }
        }
    }
}
