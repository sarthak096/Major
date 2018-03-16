//
//  PaymentViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/15/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var payonlinebtn: UIButton!
    @IBOutlet weak var cashbtn: UIButton!
    @IBOutlet weak var imgbarcode: UIImageView!
    public var openedpayment: ((String) -> ())?
    let img = PaymentViewController.fromString(string: "whateva")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cashbtn.layer.cornerRadius = 0.1 * cashbtn.bounds.size.width
        cashbtn.clipsToBounds = true
        payonlinebtn.layer.cornerRadius = 0.1 * payonlinebtn.bounds.size.width
        payonlinebtn.clipsToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cardSelected(_ sender: UIButton) {
    }
    @IBAction func cashSelected(_ sender: UIButton) {
        
         let alert = UIAlertController(title: "Payment", message: "Confirm the selected payment method?", preferredStyle: .alert)
          let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { (alert: UIAlertAction!) -> Void in
            self.imgbarcode.image = self.img
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion:nil)
            
            
    }
    class func fromString(string : String) -> UIImage? {
        
        let data = string.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        return UIImage(ciImage: (filter?.outputImage)!)
    }
    
}
