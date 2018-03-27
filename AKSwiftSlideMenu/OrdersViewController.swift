//
//  OrdersViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/15/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase

class OrdersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{
    
    var ref: DatabaseReference!
    let vc = ListTableViewController()
    var Uid:String = (Auth.auth().currentUser?.uid)!
    var tt: String = ""
    var newarray = [CartItem]()
    var titlesArray:[String] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orderLabel: UILabel!
    
    
    
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
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        
        let qref = self.ref.child("users").child(Uid).child("orders").queryOrderedByKey()
        qref.observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children{
                let usersnap = snap as! DataSnapshot
                self.tt = usersnap.key
            }
            print(self.tt)
            print("new")
            
            let dref = self.ref.child("users").child(self.Uid).child("orders").child(self.tt).queryOrderedByKey()
            dref.observeSingleEvent(of: .value, with: { (snapshot) in
                for snap in snapshot.children{
                    let new = snap as! DataSnapshot
                    let hh = new.value
                     print(self.titlesArray)
                }
               
            })
        })
    }
*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(vc.tp.count)
       // if (vc.tp.count) > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            /*
        }
        else{
            
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No previous order history"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }*/
        return newarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vc.tp[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order Cell", for: indexPath)
        print(item)
       // cell.textLabel?.text =
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
