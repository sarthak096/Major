//
//  SignUpViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SignUpViewController : UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var mobileNum: UITextField!
    @IBOutlet weak var firstName: UITextField!
    // @IBOutlet weak var resetPassword: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        mobileNum.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 3
        emailTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.returnKeyType = UIReturnKeyType.next
        firstName.returnKeyType = UIReturnKeyType.next
        mobileNum.returnKeyType = UIReturnKeyType.next
        passwordTextField.tag = 4
        firstName.tag = 0
      
        mobileNum.tag = 2
        signUp.tag = 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstName {
            textField.resignFirstResponder()
            mobileNum.becomeFirstResponder()
        }else if textField == mobileNum {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField{
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            textField.resignFirstResponder()
            signUp.becomeFirstResponder()
        }else if textField == signUp {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        // let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
        //  appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: //Bundle.main).instantiateInitialViewController()
        
        if emailTextField.text! == "" || firstName.text! == "" || mobileNum.text! == "" || passwordTextField.text! == ""{
            let alertController = UIAlertController(title: "Sorry", message: "Please fill in all the details.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK",style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error)
                in
                if error == nil{
                    print("You have successfully signed up")
                    let userData = ["name":self.firstName,"mobile":self.mobileNum]
                    let ref = Database.database().reference()
                    ref.child("users").child(user!.uid).setValue(userData)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "abc")
                    self.present(vc!, animated: true, completion: nil)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

