//
//  SignInVC.swift
//  HypeSocial
//
//  Created by Pasha Bahadori on 9/20/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
     
    }

    //Segueways to be performed off the bat need to be in viewDidAPPEAR not didLoad
    override func viewDidAppear(_ animated: Bool) {
        //This is checking the string in the uid, in the keychain - if it finds one, perform the segueway to go to FeedVC
        if let _ = KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
  

    //We have two authentications - one with Facebook and one with Firebase
    // How it works with Facebook is we have our authenticator with Facebook, "Yes FB I have allowed this app permissions to access elements in my Facebook Profile like my FB email, username, etc
    //So first step is to check in with Facebook to see if we can go ahead and access user FB info
    @IBAction func facebookBtnTapped(_ sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("PASH: Unable to authenticate with Facebook - \(error)")
            }
            
                //So if we haven't received an error, something else might happen. This is what to do if the user clicks cancel
            else if result?.isCancelled == true {
                print("PASH: User cancelled Facebook Authentication")
            } else {
                print("PASH: Successfully authenticated with Facebook!")
                
                //You want to get the Facebook credential and the FB credential is what is used to authenticate with Firebase
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                //In a completion handler, you need to put self infront of the class' function
                self.firebaseAuth(credential)
            }
        }
        
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        //We're authenticting with Firebase here using our Facebook credential
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("PASH: Unable to authenticate with Firebase - \(error)")
            } else {
                print("PASH: Successfully authenticated with Firebase!")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        })
    }
    
    
    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("PASH: Email user authenticated with Firebase")
                    if let user = user {
                          self.completeSignIn(id: user.uid)
                    }
                  
                } else {
                    //List out error scenarios - Lookup Firebase Documentation on how to correctly do this
                    //For this example, we'll create a new user
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                             print("PASH: Unable to authenticate with Firebase using email \(error)")
                        } else {
                            print("PASH: Successfully authenticated with Firebase")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                   /*Create User Block End */ })
                }
            })
        }
    }/*SIGN IN FUNC END */
    
    //Saving user's UID to their keychain
    func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.defaultKeychainWrapper().setString(id, forKey: KEY_UID)
        print("PASH: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    

}

