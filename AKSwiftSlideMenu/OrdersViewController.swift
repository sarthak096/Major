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
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Item Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.reloadData()
        ref = Database.database().reference()
        print(Uid)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
     return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Order1 Cell")
        //Fetch Firebase Data
        let qref = self.ref.child("users").child(Uid).child("orders").queryOrderedByKey()
        qref.observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children{
                let usersnap = snap as! DataSnapshot
                print("Hello")
                //self.titlesArray.append(item!)
                cell.detailTextLabel?.text = usersnap.value as? String
                cell.textLabel?.text = usersnap.key as? String
                print(usersnap.key)
                print(usersnap.value)
            }
            print(self.titlesArray)
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
