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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        checkOut.layer.cornerRadius = 0.2 * checkOut.bounds.size.width
        tableView.allowsMultipleSelectionDuringEditing = false
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
}


