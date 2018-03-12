//
//  ProfileViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: BaseViewController{
    
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var logOut: UIButton!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        logOut.layer.cornerRadius = 0.08 * logOut.bounds.size.width
        logOut.clipsToBounds = true
          }
    
    @IBAction func logoutAction(_ sender: Any) {
        // unauth() is the logout method for the current user.
        
        do{
            try Auth.auth().signOut()
            // Remove the user's uid from storage.
            
            UserDefaults.standard.setValue(nil, forKey: "uid")
            
            // Head back to Login!
            
            //self.performSegueWithIdentifier("logoutSegue", sender: self)
        }catch{
            print("Error while signing out!")
        }
        
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login")
        UIApplication.shared.keyWindow?.rootViewController = loginViewController
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
  
}

