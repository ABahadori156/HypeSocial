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

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
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
