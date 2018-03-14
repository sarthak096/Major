//
//  ProfileViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

protocol ProfileViewControllerDelegate: class {
    
    func textChanged(text:String?)
    
}
class ProfileViewController: BaseViewController{
    
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var logOut: UIButton!
    var username = abc.globalVariable.userName;

    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
       // let colors:[UIColor] = [UIColor.flatRed,UIColor.flatWhite]
       // view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        logOut.layer.cornerRadius = 0.1 * logOut.bounds.size.width
        logOut.clipsToBounds = true
        let user = Auth.auth().currentUser
        //ref.child("users").child(user!.uid).setValue(userData)
        ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                print("hello1")
                return
            }
            print("Hello")
            print("hello")
            let userDict = DataSnapshot.value as! [String: Any]
            let uname = userDict["name"] as! String
            let contact = userDict["mobile"] as! String
            let email = Auth.auth().currentUser?.email
            self.email.text = email
            //print("email: \(email)  yetki: \(yetki)")
            self.name.text = uname
            self.mobile.text = contact
        })
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

