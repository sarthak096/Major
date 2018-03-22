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
import ChameleonFramework


class SignUpViewController : UIViewController,UITextFieldDelegate{
  
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var mobileNum: UITextField!
    @IBOutlet weak var firstName: UITextField!
    // @IBOutlet weak var resetPassword: UIButton!
    @IBOutlet weak var signUp: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let colors:[UIColor] = [UIColor.flatRedDark,UIColor.flatOrange]
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        firstName.delegate = self
        mobileNum.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 3
        emailTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.returnKeyType = UIReturnKeyType.done
        firstName.returnKeyType = UIReturnKeyType.next
        mobileNum.returnKeyType = UIReturnKeyType.next
        passwordTextField.tag = 4
        firstName.tag = 0
        mobileNum.tag = 2
        signUp.tag = 5
        
        //let colors:[UIColor] = [UIColor.flatWhite,UIColor.flatRedDark]
        //view.backgroundColor = GradientColor(.radial, frame: view.frame, colors: colors)
       
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
    
    func isNameValidInput(Input:String) -> Bool {
        let myCharSet=CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let output: String = Input.trimmingCharacters(in: myCharSet.inverted)
        let isValid: Bool = (Input == output)
        return isValid
    }
    func isNumberValidInput(Input:String) -> Bool {
        let myCharSet=CharacterSet(charactersIn:"0123456789")
        let output: String = Input.trimmingCharacters(in: myCharSet.inverted)
        let isValid: Bool = (Input == output)
        return isValid
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        
        if emailTextField.text! == "" || firstName.text! == "" || mobileNum.text! == "" || passwordTextField.text! == "" || isNameValidInput(Input: firstName.text!) == false || isNumberValidInput(Input: mobileNum.text!) == false{
            let alertController = UIAlertController(title: "Sorry", message: "Please fill in all the details correctly.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK",style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error)
                in
                if error == nil{
                    print("You have successfully signed up")
                    let name = self.firstName.text
                    let mobile = self.mobileNum.text
                    let userData = ["name":name,"mobile":mobile]
                    
                    let ref = Database.database().reference(fromURL: "https://demoapp-a3463.firebaseio.com/")
                    guard (user?.uid) != nil else {
                        return
                    }
                    ref.child("users").child(user!.uid).setValue(userData)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "abc")
                    abc.globalVariable.userName = self.firstName.text!;
                    let new = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
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
 
