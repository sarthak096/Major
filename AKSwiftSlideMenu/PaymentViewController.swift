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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var amtLabel: UILabel!
    
    @IBOutlet weak var imgbarcode2: UIImageView!
    
    @IBOutlet weak var verify: UILabel!
    
    public var openedpayment: ((String) -> ())?
    var openHome: HomeVC?
    
    var listvc = ListTableViewController()
    var ref: DatabaseReference! = Database.database().reference()
    public var infoview: ((String) -> ())?
    var newref: DatabaseReference! = Database.database().reference()
    var Uid:String = (Auth.auth().currentUser?.uid)!
    
    //Load ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //addSlideMenuButton()
        openHome = self.storyboard!.instantiateViewController(withIdentifier: "Home") as? HomeVC
        //let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Dismiss", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPressed(_:)))
        //self.navigationItem.rightBarButtonItem = cancelButton
       // ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        emailLabel.text = Auth.auth().currentUser?.email
        let date = Date(tic: UInt64(GlobalVariables.sharedManager.ordercode)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date)
        timeLabel.text = myString
        ref.child("users").child(self.Uid).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value as! [String: Any]
            let uname = userDict["name"] as! String
            let contact = userDict["mobile"] as! String
            self.nameLabel.text = uname
            self.contactLabel.text = contact
        })
        let temptime = GlobalVariables.sharedManager.ordercode
        print("new")
        print(temptime)
        let newref = self.ref.child("users").child(self.Uid).child("orders").child(GlobalVariables.sharedManager.ordercode).queryOrderedByKey()
        newref.observe(.value, with: { (snapshot) in
            let newcount = snapshot.childrenCount
            let userDictt = snapshot.value as! [String: Any]
            let mode = userDictt["Payment mode: "] as! String
            print("Sarthak")
            print(mode)
            var amt = mode.components(separatedBy: "-")
            print(amt[0])
            print(amt[1])
            self.PaymentMode.text = amt[0]
            self.amtLabel.text = amt[1]
        })
        let img = PaymentViewController.fromString(string: "\(Uid),\(GlobalVariables.sharedManager.ordercode)")
        self.imgbarcode.image = img
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailLabel.text = Auth.auth().currentUser?.email
        let date = Date(tic: UInt64(GlobalVariables.sharedManager.ordercode)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date)
        timeLabel.text = myString
        ref.child("users").child(self.Uid).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value as! [String: Any]
            let uname = userDict["name"] as! String
            let contact = userDict["mobile"] as! String
            self.nameLabel.text = uname
            self.contactLabel.text = contact
        })
        let temptime = GlobalVariables.sharedManager.ordercode
        print("new")
        print(temptime)
        let newref = self.ref.child("users").child(self.Uid).child("orders").child(GlobalVariables.sharedManager.ordercode).queryOrderedByKey()
        newref.observe(.value, with: { (snapshot) in
            let newcount = snapshot.childrenCount
            let userDictt = snapshot.value as! [String: Any]
            let mode = userDictt["Payment mode: "] as! String
            let verify = userDictt["Verified: "] as! String
            print("Sarthak")
            print(mode)
            var amt = mode.components(separatedBy: "-")
            print(amt[0])
            print(amt[1])
            self.PaymentMode.text = amt[0]
            self.amtLabel.text = amt[1]
            self.verify.text = verify
        })
        let img = PaymentViewController.fromString(string: "\(Uid),\(GlobalVariables.sharedManager.ordercode)")
        print("\(Uid)\(GlobalVariables.sharedManager.ordercode)")
        //let img2 = PaymentViewController.fromString(string: "\(GlobalVariables.sharedManager.ordercode)")
       // self.imgbarcode.transform = CGAffineTransform(rotationAngle: (90.0 * .pi) / 1)
        self.imgbarcode.image = img
        //self.imgbarcode2.image = img2
        print("\(Uid),\(GlobalVariables.sharedManager.ordercode)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Generate barcode
    class func fromString(string : String) -> UIImage? {
        let data = string.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")

        filter?.setValue(data, forKey: "inputMessage")
        
        return UIImage(ciImage: (filter?.outputImage)!)
    }
    
}
extension Date {
    init(tic:UInt64) {
        self.init(timeIntervalSince1970: Double(tic)/10_000_000 - 62_135_596_800)
    }
}
