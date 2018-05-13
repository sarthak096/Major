//
//  OrdersViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/15/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase
import CRRefresh

class OrdersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{
    
    var ref: DatabaseReference! = Database.database().reference()
    let vc = ListTableViewController()
    var Uid:String = (Auth.auth().currentUser?.uid)!
    var tt: String = ""
    var newarray = [CartItem]()
    var titlesArray:[String] = []
    @IBOutlet var tableView: UITableView!
    var newitem = [String]()
    var arr:[String] = []
    var arrquant:[String] = []
    var new:[String] = []
    var paymode:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Order Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        tableView.rowHeight = 110.0
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()){[weak self] in
            self?.ref.child("users").child((self?.Uid)!).child("orders").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
                print(GlobalVariables.sharedManager.orderscount)
                print("Load")
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.tableView.cr.endHeaderRefresh()
            })
            self?.tableView.reloadData()
        }
        tableView.cr.beginHeaderRefresh()
        print("opened")
        
       
    }
    //Reload TableView
    @objc func loadList(){
        self.isEditing = !self.isEditing
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("1new")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ref.child("users").child(Uid).child("orders").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
            print(GlobalVariables.sharedManager.orderscount)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GlobalVariables.sharedManager.orderscount > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Order History"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
     return GlobalVariables.sharedManager.orderscount
    print("11")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("111")
      let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Order Cell")
        //let cell = table.dequeueReusableCell(withIdentifier: "Order Cell")
        //Fetch Firebase Data
        let qref = self.ref.child("users").child(Uid).child("orders").queryOrderedByKey()
        qref.observeSingleEvent(of: .value, with: { (snapshot) in
            GlobalVariables.sharedManager.orderarray.removeAll()
            for snap in snapshot.children{
                let usersnap = snap as! DataSnapshot
                print("Hello")
                let code = (usersnap.key as? String)
                GlobalVariables.sharedManager.orderarray.append(code!)
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
            newref.observe(.value, with: { (snapshot) in
                let newcount = snapshot.childrenCount
                let userDictt = snapshot.value as! [String: Any]
                let mode = userDictt["Payment mode: "] as! String
                for i in 0...newcount-2{
                    let price = userDictt["Item: \(i)"] as! String
                    var delimiter = ","
                    var newstr = price
                    var token = newstr.components(separatedBy: delimiter)
                    self.arr.append(token[0])
                    self.arrquant.append(token[1])
                    self.paymode.append(mode)
                    let temp = token[0]
                   
                    self.ref.child("Database").child(temp).observeSingleEvent(of: .value, with: { DataSnapshot in
                        if !DataSnapshot.exists(){
                            return
                        }
                        let userDict = DataSnapshot.value as! [String: Any]
                        let qdesc = userDict["Description"] as! String
                        print("de")
                        print(qdesc)
                        
                    })
                    
                    self.new.append("Item: " + token[0] + "    Quantity: " + token[1])
                }
                print("FInal")
                print(self.new)
                var string = self.new.joined(separator:"\n") + "\n" + "Payment Mode: " + mode
                cell.detailTextLabel?.numberOfLines = 10
                cell.detailTextLabel?.text = string
                self.new.removeAll()
                self.arr.removeAll()
                self.paymode.removeAll()
                self.arrquant.removeAll()
            })
        })
        return cell
        print("1111")
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension Date {
    init(ticks:UInt64) {
        self.init(timeIntervalSince1970: Double(ticks)/10_000_000 - 62_135_596_800)
    }
}
