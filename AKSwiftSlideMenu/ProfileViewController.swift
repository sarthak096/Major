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
class ProfileViewController: BaseViewController,UITextFieldDelegate{
    
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userContact: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userAddress: UITextField!
    
    var editTextFieldToggle: Bool = false
    var username = abc.globalVariable.userName;
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
        userName.delegate = self
        userContact.delegate = self
        userEmail.delegate = self
        userAddress.delegate = self
        userName.tag = 0
        userContact.tag = 1
        userEmail.tag = 2
        userAddress.tag = 3
        userName.returnKeyType = UIReturnKeyType.next
        userContact.returnKeyType = UIReturnKeyType.next
        userEmail.returnKeyType = UIReturnKeyType.next
        userAddress.returnKeyType = UIReturnKeyType.done
        
       // let colors:[UIColor] = [UIColor.flatRed,UIColor.flatWhite]
       // view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        logOut.layer.cornerRadius = 0.1 * logOut.bounds.size.width
        logOut.clipsToBounds = true
        let user = Auth.auth().currentUser
        //ref.child("users").child(user!.uid).setValue(userData)
        ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value as! [String: Any]
            let uname = userDict["name"] as! String
            let contact = userDict["mobile"] as! String
            let email = Auth.auth().currentUser?.email
            self.userEmail.text = email
            self.userName.text = uname
            self.userContact.text = contact
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == userName {
            textField.resignFirstResponder()
            userContact.becomeFirstResponder()
        }else if textField == userContact {
            textField.resignFirstResponder()
            userEmail.becomeFirstResponder()
        } else if textField == userEmail{
            textField.resignFirstResponder()
             userAddress.becomeFirstResponder()
        }else if textField == userAddress{
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        editTextFieldToggle = !editTextFieldToggle
        if editTextFieldToggle == true {
            navigationItem.rightBarButtonItem = editBtn
            let edit = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(editPressed(_:)))
            navigationItem.rightBarButtonItem = edit
            textFieldActive()
            
        } else {
            navigationItem.rightBarButtonItem = editBtn
            let edit = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPressed(_:)))
            navigationItem.rightBarButtonItem = edit
            textFieldDeactive()
            
        }
    }
    
    func textFieldActive(){

        userName.isUserInteractionEnabled = true
        userName.becomeFirstResponder()
        userContact.isUserInteractionEnabled = true
        userEmail.isUserInteractionEnabled = true
        userAddress.isUserInteractionEnabled = true
    }
    
    func textFieldDeactive(){

        userName.isUserInteractionEnabled = false
        userContact.isUserInteractionEnabled = false
        userEmail.isUserInteractionEnabled = false
        userAddress.isUserInteractionEnabled = false
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

