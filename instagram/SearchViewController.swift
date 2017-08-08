//
//  SearchViewController.swift
//  instagram
//
//  Created by Luiz Hammerli on 06/08/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    var users = [User]()
    var filteredUsers = [User]()
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.barTintColor = .gray
        sb.placeholder = "Search"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = .white
        registerCells()
        setUpViews()
        fetchUsers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            filteredUsers = users
        }else{
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView?.reloadData()
    }
    
    func registerCells(){
        self.collectionView?.register(SearchListCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setUpViews(){
        self.navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar        
        searchBar.anchor(top: navBar?.topAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, left: navBar?.leftAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: -8, height: nil, width: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 66)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = filteredUsers[indexPath.item]
        userProfileController.navigationItem.title = filteredUsers[indexPath.item].name
        self.navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchListCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func fetchUsers(){
        
        Firebase.Database.database().reference().child("user").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String:Any] else {return}
            
            dict.forEach({(key, value) in
                
                if (key == Firebase.Auth.auth().currentUser?.uid){
                    return
                }
                
                guard let userDict = value as? [String: Any] else {return}
                
                let user = User(id: key, name: userDict["name"] as! String, profileImageUrl: userDict["profileImageUrl"] as! String)
                
                self.users.append(user)
            })
            
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.name.compare(u2.name) == .orderedAscending
            })
            
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
        })
    }
}
