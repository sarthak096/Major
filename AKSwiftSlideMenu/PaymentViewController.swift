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
    @IBOutlet weak var PaymentMode: UILabel!
    @IBOutlet weak var imgbarcode: UIImageView!
    public var openedpayment: ((String) -> ())?
    var openHome: HomeVC?
    let img = PaymentViewController.fromString(string: "whateva")
    var listvc = ListTableViewController()
    var ref: DatabaseReference!
    
    //Load ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //addSlideMenuButton()
        self.imgbarcode.image = self.img
        openHome = self.storyboard!.instantiateViewController(withIdentifier: "Home") as? HomeVC
        self.navigationItem.setHidesBackButton(true, animated: true)
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Dismiss", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPressed(_:)))
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
        let alert = UIAlertController(title: "Save the receipt", message: "Please save the receipt by taking a screenshot or first show it to the staff members on exit", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        let cancel =  UIAlertAction(title: "No", style: .destructive, handler: { (alert:UIAlertAction!) -> Void in
            
        })
        let confirm = UIAlertAction(title: "Yes", style: .default, handler: { (alert:UIAlertAction) -> Void in
            
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
    
    //Generate barcode
    class func fromString(string : String) -> UIImage? {
        let data = string.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        return UIImage(ciImage: (filter?.outputImage)!)
    }
    
}
