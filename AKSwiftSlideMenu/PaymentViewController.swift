//
//  PaymentViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/15/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase

class PaymentViewController:BaseViewController {
    
    //Outlets and Variables
    
    @IBOutlet weak var payonlinebtn: UIButton!
    @IBOutlet weak var cashbtn: UIButton!
    @IBOutlet weak var imgbarcode: UIImageView!
    public var openedpayment: ((String) -> ())?
    var openHome: HomeVC?
    let img = PaymentViewController.fromString(string: "whateva")
    var listvc: ListTableViewController?
    var ref: DatabaseReference!
    
    //Load ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //addSlideMenuButton()
        cashbtn.layer.cornerRadius = 0.1 * cashbtn.bounds.size.width
        cashbtn.clipsToBounds = true
        payonlinebtn.layer.cornerRadius = 0.1 * payonlinebtn.bounds.size.width
        payonlinebtn.clipsToBounds = true
        openHome = self.storyboard!.instantiateViewController(withIdentifier: "Home") as? HomeVC
        self.navigationItem.setHidesBackButton(true, animated: true)
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPressed(_:)))
        self.navigationItem.rightBarButtonItem = cancelButton
        ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Handles Card Paymetns
    @IBAction func cardSelected(_ sender: UIButton) {
    }
    
    //Handles order cancellation
    @objc func cancelPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Cancel order?", message: "Are you sure you want to continue and cancel your order? ", preferredStyle: .alert)
        let cancel =  UIAlertAction(title: "No", style: .destructive, handler: { (alert:UIAlertAction!) -> Void in
            
        })
        let confirm = UIAlertAction(title: "Yes", style: .default, handler: { (alert:UIAlertAction) -> Void in
            
           // self.ref.child("orders").re
            self.openHome?.openedHome = { (barcode: String) in
                _ = self.navigationController?.popViewController(animated: true)
            }
            if let openHome = self.openHome{
                self.navigationController?.pushViewController(openHome, animated: true)
            }
        })
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true,completion: nil)
    }
    
    //Handles Cash Payemnt
    @IBAction func cashSelected(_ sender: UIButton) {
        
         let alert = UIAlertController(title: "Payment", message: "Confirm the selected payment method?", preferredStyle: .alert)
          let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert: UIAlertAction!) -> Void in
            
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (alert: UIAlertAction!) -> Void in
            //set Barcode
            self.imgbarcode.image = self.img
        //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion:nil)
            
            
    }
    
    //Generate barcode
    class func fromString(string : String) -> UIImage? {
        let data = string.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        return UIImage(ciImage: (filter?.outputImage)!)
    }
    
}
