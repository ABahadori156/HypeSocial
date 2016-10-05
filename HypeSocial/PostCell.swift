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
    @IBOutlet weak var likesImg: UIImageView!
    
    
    var post: Post!
    
    //You can't have a let constant without an initial value so make it a var
    var likesRef: FIRDatabaseReference!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //TAPGESTURE RECOGNIZER FOR LIKES
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        
        
    }
    
    //The UIImage? = nil will make the img parameter a default of nil if there is nothing there. So if you call the below function and don't pass in anything to it, it will just use that default value. 
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
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
        

        //LIKES #2
         //So everytime this cell is configured, it will check if it's liked or not by the current user and then it will display the image depending on the result of whether the cell is liked or not
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Because we're working with Firebase, it's not nil, it's NSNull which Firebase works with.
            if let _ = snapshot.value as? NSNull {
                //If this is null, we will look for a like on this post by this current user, if it's null and we don't get a like, then we'll set our like image 
                self.likesImg.image = UIImage(named: "empty-heart")
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
            }
        })
        }
    
    
    //LIKES BUTTON TAPPED
    func likeTapped(sender: UITapGestureRecognizer) {
        
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // If it's NOT liked, we want to change it to liked. If it is liked, we want to take it back to empty.
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "filled-heart")
                //Now we adjust the number of likes accordingly 
                self.post.adjustLikes(addLike: true)
                
                //Number of lieks in a Post class has gone up one and we need to update that in the Firebase Database
                //Here we want to update a reference to that person liking it on Firebase - You can like it or not only
                self.likesRef.setValue(true)
            } else {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    

 

}
