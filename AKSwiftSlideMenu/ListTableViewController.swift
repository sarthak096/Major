//
//  PlayVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import Firebase
import CoreData


class ListTableViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var checkOut: UIButton!
    let list = "List"
    @IBOutlet var tableView: UITableView!
    var tp:[String] = []
    var pcart: [NSManagedObject] = []
    //var items:[String] = []
    var openpayment: PaymentViewController?
    @IBOutlet weak var clear: UIButton!
    var new : String = ""
    var id:String = (Auth.auth().currentUser?.uid)!
    var ref: DatabaseReference!
    
    
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
        ref = Database.database().reference()
        
    }
    
    @objc func loadList(){
        self.isEditing = !self.isEditing
       self.tableView.reloadData()
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
    
    func clearCart(){
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
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        let alertView = UIAlertController(title: "Clear all?", message: "Do you really want to clear all items from your cart?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        alertView.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (alertAction) -> Void in
            self.clearCart()
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
                self.clearCart()
                let new = NSArray(array: self.tp)
                var time = String(Date().ticks)
                
                self.ref.child("users").child(self.id).child("orders").childByAutoId().setValue(["item":new])
            
                let qref = self.ref.child("users").child(self.id).child("orders").queryOrderedByKey()
                var tt = ""
                qref.observeSingleEvent(of: .value, with: { (snapshot) in
                    for snap in snapshot.children{
                        let usersnap = snap as! DataSnapshot
                        tt = usersnap.key
                    }
                    print(tt)
                    self.ref.child("users").child(self.id).child("orders").child(tt).child("time").setValue(Date().ticks)
                })
                print(self.tp.count)
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
extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}



