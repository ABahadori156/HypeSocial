//
//  Post.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 10/1/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(caption: String, imageUrl: String, likes: Int, postKey: String) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        
    }
    
    //This init method is what we'll use to convert the data from Firebase into something we can use in our app
    init(postKey: String, postData: Dictionary<String, Any>) {
        self._postKey = postKey
        
        //WE're getting the post data from Firebase so we have to add this check cause it might not be there.
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        //Here we get a database reference to the posts - In this location we can update the likes
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
        
        
    }
    
    //LIKES
    //We need a boolean to check if we add one or take one away
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    
}



