//
//  DataService.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 10/1/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()    //This will contain the URL of the root of our database

class DataService {
    
    //We need certain end points we want to look for at data. We'll look at posts and users
    //We're going to create a Singleton. It's an instance of a class that is globally accessible and it's the only instance in the app
    
    static let ds = DataService()   //This line creates the Singleton
    
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    //Now we want to use these references to create users to post some data to the Firebase Database
    //It's important to differentiate between a DB user and the users we are authenticating - they're the same people, but we handle the data differently. 
    //We can capture information about the user and put that in our database and we can use that to reference that to relationships with like posts to likes, etc.
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        //We want to save the user to Firebase so first we create a reference to the location in the database we want to save the user too
        //The location is a child of "users", and if the uid is not there, Firebase will create one
        REF_USERS.child(uid).updateChildValues(userData)
        
        //What updateChildValues does is create the uid if it's not there, and then it's updating  the uid child values
        //If the data does exist, it WON'T override it. It'll just add data to it if that data is not already there. 
        
        //SetValue will overwrite the data, getting rid of data that was there previously
    }
    
}









