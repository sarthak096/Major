//
//  OrdersViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/15/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase


class TestTableViewCell: UITableViewCell{
    
    
    @IBOutlet weak var Itemdata: UILabel!
    @IBOutlet weak var Itemcode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class OrdersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{
    
    var ref: DatabaseReference!
    let vc = ListTableViewController()
    var Uid:String = (Auth.auth().currentUser?.uid)!
    var tt: String = ""
    var newarray = [CartItem]()
    var titlesArray:[String] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orderLabel: UILabel!
    var newitem = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.reloadData()
        ref = Database.database().reference()
        GlobalVariables.sharedManager.orderarray.removeAll()
        print(Uid)
        ref.child("users").child(Uid).child("orders").observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                ref.child("users").child(Uid).child("orders").observe(.value, with: { (DataSnapshot) in
            GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return GlobalVariables.sharedManager.orderscount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

       let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Order Cell")
        //Fetch Firebase Data
      
        let qref = self.ref.child("users").child(Uid).child("orders").queryOrderedByKey()
        qref.observeSingleEvent(of: .value, with: { (snapshot) in
            GlobalVariables.sharedManager.orderarray.removeAll()
            for snap in snapshot.children{
                let usersnap = snap as! DataSnapshot
                print("Hello")
                //let userDict = snapshot.children.allObjects as! [String]
                //let desc = userDict["Item:"] as! String
                //print(userDict)
                let code = (usersnap.key as? String)
                GlobalVariables.sharedManager.orderarray.append(code!)
                
               // cell.detailTextLabel?.text = usersnap.value
            }
            print("Array")
            print(GlobalVariables.sharedManager.orderarray)
            
            
            let tt = GlobalVariables.sharedManager.orderarray[indexPath.row]
            let date = Date(ticks: UInt64(tt)!)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let myString = formatter.string(from: date)
            cell.textLabel?.text = ("Time: " + myString)
            let newref = self.ref.child("users").child(self.Uid).child("orders").child(GlobalVariables.sharedManager.orderarray[indexPath.row]).queryOrderedByKey()
            newref.observeSingleEvent(of: .value, with: { (snapshot) in
                let count = Int(snapshot.childrenCount)
                print(count)
                let userDict = snapshot.value as! [String: Any]
                for i in 0...count-1{
                let price = userDict["Item: \(i)"] as! String
                print(price)
                    var delimiter = ","
                    var newstr = price
                    var token = newstr.components(separatedBy: delimiter)
                    print (token[0])
                    cell.detailTextLabel?.text = ("Item: " + token[0] + "    Quantity: " + token[1])
                }
            })
        })
        
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension Date {
    init(ticks: UInt64) {
        self.init(timeIntervalSince1970: Double(ticks)/10_000_000 - 62_135_596_800)
    }
}
