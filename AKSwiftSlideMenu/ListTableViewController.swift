//
//  PlayVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ListTableViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var checkOut: UIButton!
    
    let list = "List"
    @IBOutlet var tableView: UITableView!
    var items:[CartItem] = []
    let ref = Database.database().reference(withPath: "cart-items")
    var openpayment: PaymentViewController?
    
    @IBOutlet weak var clear: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
         openpayment = self.storyboard!.instantiateViewController(withIdentifier: "Payment") as? PaymentViewController
        
       // checkOut.layer.cornerRadius = 0.04 * checkOut.bounds.size.width
      //  checkOut.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref.queryOrdered(byChild: "completed").observe(.value,with:{snapshot in
            var newItems: [CartItem] = []
            for item in snapshot.children {
                let cartItem = CartItem(snapshot: item as! DataSnapshot)
                newItems.append(cartItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    @objc func loadList(){
        //load data here
        self.isEditing = !self.isEditing
        self.items.removeAll()
        self.tableView.reloadData()
        self.ref.removeValue()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if items.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No items"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item Cell", for: indexPath)
        let cartItem = items[indexPath.row]
        cell.textLabel?.text = cartItem.name
        print(cartItem.name)
        toggleCellCheckbox(cell, isCompleted: cartItem.completed)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cartItem = items[indexPath.row]
            cartItem.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        let cartItem = items[indexPath.row]
        let toggledCompletion = !cartItem.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        cartItem.ref?.updateChildValues(["comleted": toggledCompletion])
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool){
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
        }
        else{
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
        }
    }
    @IBAction func clearPressed(_ sender: UIButton) {
        let alertView = UIAlertController(title: "Clear all?", message: "Do you really want to clear all items from your cart?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { (alertAction) -> Void in
            self.isEditing = !self.isEditing
            self.items.removeAll()
            self.tableView.reloadData()
            self.ref.removeValue()
        }))
        present(alertView, animated: true, completion: nil)
 
    }
    @IBAction func checkoutPressed(_ sender: UIButton) {
        
        openpayment?.openedpayment = { (barcode: String) in
            _ = self.navigationController?.popViewController(animated: true)
            //print("Received following barcode: \(barcode)")
        }
        if let openpayment = self.openpayment{
            self.navigationController?.pushViewController(openpayment, animated: true)
        }
        
    }
}


