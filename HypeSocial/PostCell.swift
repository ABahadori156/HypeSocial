//
//  PostCell.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 10/1/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    var post: Post!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //The UIImage? = nil will make the img parameter a default of nil if there is nothing there. So if you call the below function and don't pass in anything to it, it will just use that default value. 
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        self.caption.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        
        //Download the image in ConfigureCell - We'll check in our cache if we have the image locally, if we do, we'll grab it
        if img != nil {
            self.postImg.image = img
        } else {

                //This is where we'll be grabbing the imageUrl from Firebase Storage
                let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
                
                //This will max size the image we download because we want to limit the size for performance
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("PASH: Unable to download image from Firebase storage")
                    } else {
                        print("PASH: Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                //Here we download the images and save them to cache
                                self.postImg.image = img
                                FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                                print("PICTURE: \(post.imageUrl)")
                            }
                        }
                    }
                })
            }
        }
    
    

 

}
