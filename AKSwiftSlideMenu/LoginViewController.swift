//
//  LoginViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth


class LoginViewController: UIViewController,UITextFieldDelegate{
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 0
        emailTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.tag = 1
        login.tag = 2
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField{
            textField.resignFirstResponder()
            login.becomeFirstResponder()
        } else if textField == login {
            textField.resignFirstResponder()
        }
        return true
    }
    @IBAction func loginAction(_ sender: UIButton) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
            appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    
                    
                    print("You have successfully logged in")
                    
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "abc")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    
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
