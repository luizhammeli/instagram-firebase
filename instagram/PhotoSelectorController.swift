//
//  PhotoSelectorController.swift
//  instagram
//
//  Created by Luiz Hammerli on 18/06/17.
//  Copyright © 2017 Luiz Hammerli. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    var images: [UIImage] = []
    var headerImage: UIImage?
    var assets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        setBarButtons()
        self.collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView?.register(PhotoSelectorCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchPhoto()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    fileprivate func fetchPhotoOptions() -> PHFetchResult<PHAsset>{
        let fetchOptions = PHFetchOptions()
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sort]
        return PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    fileprivate func fetchPhoto(){
        
        DispatchQueue.global().async {
            
            let allPhotos = self.fetchPhotoOptions()
            
            allPhotos.enumerateObjects({ (asset, count, stop) in
                let imageManager = PHImageManager()
                let targetSize = CGSize(width: 250, height: 250)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (image, info) in
                    
                    if let image = image{
                        self.images.append(image)
                        self.headerImage = self.images[0]
                        self.assets.append(asset)
                        
                        if count == 0 {
                            self.headerImage = image
                        }
                    }
                    
                    if count == allPhotos.count - 1{
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                        
                    }
                })
            })
        }
    }
    
    func setBarButtons(){
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismissPhotoSelectorController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goNextStep))
    }
    
    func dismissPhotoSelectorController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func goNextStep(){
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = headerImage
        self.navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        headerImage = images[indexPath.item]
        self.collectionView?.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.frame.width-3)/4
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return  CGSize(width: self.view.frame.width, height: self.view.frame.width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let cell = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorCell
        
        if let image = headerImage{
            
            if let index = images.index(of: image){
                
                let imageManager = PHImageManager()
                let targetSize = CGSize(width: 600, height: 600)
                let options = PHImageRequestOptions()
                
                imageManager.requestImage(for: assets[index], targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (image, info) in
                    cell.photoImageView.image = image
                    self.headerImage = image
                })
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
}
