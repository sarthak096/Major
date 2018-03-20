//
//  PlayVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreData


class ListTableViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var checkOut: UIButton!
    let list = "List"
    @IBOutlet var tableView: UITableView!
    var tp:[String] = []
    var pcart: [NSManagedObject] = []
    
    var items:[String] = []
    let ref = Database.database().reference().child("users").childByAutoId().child("cart")
    var openpayment: PaymentViewController?
    @IBOutlet weak var clear: UIButton!
    var new : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Item Cell")
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
         openpayment = self.storyboard!.instantiateViewController(withIdentifier: "Payment") as? PaymentViewController
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        /*
        ref.queryOrdered(byChild: "completed").observe(.value,with:{snapshot in
            var newItems: [CartItem] = []
            for item in snapshot.children {
                let cartItem = CartItem(snapshot: item as! DataSnapshot)
                newItems.append(cartItem)
            }
            self.items = newItems

            self.tableView.reloadData()
        })
         */
    }
    @objc func loadList(){
        //load data here
        self.isEditing = !self.isEditing
       // self.items.removeAll()
       self.tableView.reloadData()
      //  self.ref.removeValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cartdata")
        do {
            pcart = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if pcart.count > 0 {
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
        return pcart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cartname = pcart[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item Cell", for: indexPath)
       // let cartItem = items[indexPath.row]
        cell.textLabel?.text = cartname.value(forKey: "itemname") as? String
        
        new = (cartname.value(forKey: "itemname") as? String)!
        print(new)
        //print(cartItem.name)
       // toggleCellCheckbox(cell, isCompleted: cartItem.completed)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        if editingStyle == .delete {
            let objectdelete = pcart[indexPath.row]
            pcart.remove(at: indexPath.row)
            managedContext.delete(objectdelete)
            do{
                try appDelegate.saveContext()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error as NSError{
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
    }
    
    func pass (){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let num = pcart.count
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cartdata")
         for index in 0...num-1{
        do {
            let ab = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)[index] as! NSManagedObject
            tp.append(ab.value(forKey: "itemname") as! String)
            } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
                }
            }
         print(tp)
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        let alertView = UIAlertController(title: "Clear all?", message: "Do you really want to clear all items from your cart?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        alertView.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (alertAction) -> Void in
            self.isEditing = !self.isEditing
            for index in self.pcart{
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
            print(self.pcart.count)
            managedContext.delete(index)
            }
            self.pcart.removeAll()
            self.tableView.reloadData()
        }))
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func checkoutPressed(_ sender: UIButton) {
        
        if pcart.count <= 0 {
            let alert = UIAlertController(title: "Empty cart", message: "There are no items in the cart to checkout.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert,animated: true,completion: nil)
        }
            
        else{
            pass()
            let alertnew = UIAlertController(title: "Confirm Checkout?", message: "Are you sure you want to proceed with checkout?", preferredStyle: .alert)
            alertnew.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (alertAction) -> Void in
            }))
            alertnew.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) -> Void in
                
           
                /*
                 // 2
                 let cartItem = CartItem(name: metadataObj.stringValue!,
                 completed: false)
                 // 3
                 let cartItemRef = self.ref.child(metadataObj.stringValue!.lowercased())
                 
                 // 4
                 cartItemRef.setValue(cartItem.toAnyObject())
                 */
                
                self.openpayment?.openedpayment = { (barcode: String) in
                    _ = self.navigationController?.popViewController(animated: true)
                }
                if let openpayment = self.openpayment{
                    self.navigationController?.pushViewController(openpayment, animated: true)
                }
            }))
           
            present(alertnew,animated: true,completion: nil)
       
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableViewRowAnimation.fade)
            }
        case NSFetchedResultsChangeType.insert:
            print("NSFetchedResultsChangeType.Insert detected")
        case NSFetchedResultsChangeType.move:
            print("NSFetchedResultsChangeType.Move detected")
        case NSFetchedResultsChangeType.update:
            print("NSFetchedResultsChangeType.Update detected")
            tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
    
}


