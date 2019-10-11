//
//  temp.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 10/8/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

class temp: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var SelectedAssets = [PHAsset]()
    var PhotoArray = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addImages(_ sender: Any) {
        // create an instance
        let vc = BSImagePickerViewController()
        
        //display picture gallery
        self.bs_presentImagePickerController(vc, animated: true,
                                             select: { (asset: PHAsset) -> Void in
                                                
        }, deselect: { (asset: PHAsset) -> Void in
            // User deselected an assets.
            
        }, cancel: { (assets: [PHAsset]) -> Void in
            // User cancelled. And this where the assets currently selected.
        }, finish: { (assets: [PHAsset]) -> Void in
            // User finished with these assets
            for i in 0..<assets.count
            {
                
                
//                self.getImagesFromAsset(anAsset: assets[i])
                self.SelectedAssets.append(assets[i])
            
            }
            
            self.convertAssetToImages()
            
        }, completion: nil)
    }
    
    func getImagesFromAsset(anAsset: PHAsset) {
        PHImageManager.default().requestImage(for: anAsset, targetSize: CGSize(width: 600, height: 600), contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
            //resultHandler have info ([AnyHashable: Any])
            print(info!["PHImageFileURLKey"]!)
            if let img = image {
//                self.imgv.image = img
            }
        })
    }
    func convertAssetToImages() -> Void {
        
        if SelectedAssets.count != 0{
            
            
            for i in 0..<SelectedAssets.count{
                
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                
               
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                
                    print(info)
                    
                })
                
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
              
                
                self.PhotoArray.append(newImage! as UIImage)
                
            }
           
            self.imageView.animationImages = self.PhotoArray
            self.imageView.animationDuration = 3.0
            self.imageView.startAnimating()
            
        }
        
        
        print("complete photo array \(self.PhotoArray)")
    }

}
