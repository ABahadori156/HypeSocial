//
//  FeedVC.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 9/30/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Initializes the listener when this view loads in memory - listens out for changes
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            //We need to break it out into individual objects - the snapshot's value
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                        //We have an array of posts and we append each post in the forloop
                    }
                }
            }
            self.tableView.reloadData()
        })  /* End of Snapshot Observe*/
        
    } /* End of ViewDidLoad*/
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //If the image is the image that the user is editing then .. Set the image of our imageAdd button to the edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
        } else {
            print("PASH: A valid image wasn't selected")
        }
        //Once we've selected an image, dismiss the picker
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
       
        present(imagePicker, animated: true, completion: nil)
    }
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Going to show the posts in our tableView
        let post = posts[indexPath.row]
        print("PASH: \(post.caption)")
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostCell()
        }
       
    }
    
    
    //SIGN OUT
    //1. We want to sign out of Firebase
    //2. Remove uid from keychain
    @IBAction func SignOutTapped(_ sender: AnyObject) {
        let keychainResult = KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(KEY_UID)
        print("PASH: ID removed from Keychain: \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
 
    

 

}
