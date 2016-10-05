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
    @IBOutlet weak var captionField: FancyField!
   
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
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
            
            //Here we clear out the posts array at the beginning of the listener so it's now cleared every time the listener fires off
            self.posts = []
            
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
    
    
    //SAVING POST TO FIREBASE
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        //User will be able to fire off a post action - but the image has to be selected first
        // Guard statement: It stops having a big chain of if let statements. This works in our case because we will be checking for many conditions
        //What a guard statement does, and you can have multiple of them together
        //So we create a constant and check if there is text in the captionField, and it also might be blank ""
        guard let caption = captionField.text, caption != "" else {
            print("PASH: Caption must be entered")
            return
            // So if we go into this and tap the action and they havent put in text in the captionField, then it will drop into this block, print "Caption Must be Entered" then exit
        }
        //Check if there is an image, IF NOT, print "An image must be selected"
        guard let img = imageAdd.image, imageSelected == true else {
            print("PASH: An image must be selected")
            return
        }
        
        //This converts our Image into Image Data which can be used to pass up to Firebase Storage - we also set it as a JPEG and compress the image file
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            //This generates a post ID - unique identifier
            let imgUid = NSUUID().uuidString
            
            //We have meta data here for our image to tell Firebase Storage that it's a JPEG we're passing in - So Firebase knows we're passing an image in
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //The child here is the image name that we are passing up. THIS IS BEFORE WE HAVE A POSTID.
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("PASH: Unable to upload image to FB Storage")
                } else {
                    print("PASH: Successfully uploaded image to Firebase storage")
                    //We get this as an absolute string since it's a URL to get the raw value
                    //We use this downloadURL to post to Firebase
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                         self.postToFirebase(imgUrl: url)
                    }
                   
                }
            }
        }
        
    }
    
    
    func postToFirebase(imgUrl: String) {
        //This is the object we'll post to Firebase Database for the post
        let post = [
            "caption": captionField.text! as String,
            "imageUrl": imgUrl as String,
            "likes": 0 as Int
            ] as [String : Any]
        //childByAutoId generates a new child location using a unique key and returns a FIRDatabaseReference to it. This is useful when the children of a Firebase Database location represents a list of items
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        //We use set value but we can do updateValue also.
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //If the image is the image that the user is editing then .. Set the image of our imageAdd button to the edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            
            //We set imageSelected to true now because this is where in the execution the user has selected an image for the post
            imageSelected = true
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
                // return cell
            } else {
                cell.configureCell(post: post)
                // return cell
             }
            return cell
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
