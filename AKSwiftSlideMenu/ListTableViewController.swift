//
//  ListTableViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase
import CoreData


class ListTableViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource{
    
    //Outlets and Variables
    @IBOutlet weak var checkOut: UIButton!
    let list = "List"
    @IBOutlet var tableView: UITableView!
    var tp:[String] = []
    var pcart: [NSManagedObject] = []
    var openpayment: PaymentViewController?
    @IBOutlet weak var clear: UIButton!
    var new : String = ""
    var new1 : String = ""
    var id:String = (Auth.auth().currentUser?.uid)!
    var ref: DatabaseReference!
    var quantity: [Int] = []
    var firedata: [String] = []
    
    
//Load ViewControllers
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
    
    //Reload TableView
    @objc func loadList(){
        self.isEditing = !self.isEditing
       self.tableView.reloadData()
    }
    
    //Create CoreData Object and FetchRequest
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
    
    //Assign Data to each cell in TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Item Cell")
        let cartname = pcart[indexPath.row]
        let new: Int = (cartname.value(forKey: "itemquantity") as? Int)!
        let str = String(new)
        cell.detailTextLabel?.text = "Quantity : " + str
        let new1 : String = (cartname.value(forKey: "itemname") as? String)!
        let str1 = String(new1)
        cell.textLabel?.text = "Item : " + str1
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Edit TableView
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
    
    //Get Data as String from NSManagedObject CoreData
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
            quantity.append(ab.value(forKey: "itemquantity") as! Int)
            } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
                }
            }
    }
    
    //Clear all contents of the TableView
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
    
    //CleanBtn Action
    @IBAction func clearPressed(_ sender: UIButton) {
        let alertView = UIAlertController(title: "Clear all?", message: "Do you really want to clear all items from your cart?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        alertView.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (alertAction) -> Void in
            self.clearCart()
        }))
        present(alertView, animated: true, completion: nil)
    }
    
    
    //CheckoutBtn Action
    @IBAction func checkoutPressed(_ sender: UIButton) {
        //To check whether UserAddress in entered
        ref.child("users").child(id).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value as! [String: Any]
            if DataSnapshot.hasChild("Address"){
        //Conditions for checkout
                if self.pcart.count <= 0 {
            let alert = UIAlertController(title: "Empty cart", message: "There are no items in the cart to checkout.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert,animated: true,completion: nil)
        }
            
        else{
            self.pass()
            let alertnew = UIAlertController(title: "Confirm Checkout?", message: "Are you sure you want to proceed with checkout?", preferredStyle: .alert)
            alertnew.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (alertAction) -> Void in
            }))
            alertnew.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) -> Void in
                self.clearCart()
                let new = NSArray(array: self.tp)
                let quant = NSArray(array: self.quantity)
                let newmut = NSMutableArray(array: new)
                let quantmut = NSMutableArray(array: quant)
                var newStr = newmut as NSArray as? [String]
                let quantStr = quantmut as NSArray as? [Int]
                var strn = "\(newStr),\(quantStr)"
                var time = String(Date().ticks)
                
                //Store CoreData to Firebase
                for i in 0...self.tp.count-1{
                    var stre = "\(new[i]),\(quant[i])"
                    self.ref.child("users").child(self.id).child("orders").child(time).child("Item: \(i)").setValue(stre)
                    print(stre)
                }
                
                let qref = self.ref.child("users").child(self.id).child("orders").queryOrderedByKey()
                var tt = ""
                qref.observeSingleEvent(of: .value, with: { (snapshot) in
                    for snap in snapshot.children{
                        let usersnap = snap as! DataSnapshot
                        tt = usersnap.key
                    }
                })
                
                //Instantiate PaymentViewController
                self.openpayment?.openedpayment = { (barcode: String) in
                    _ = self.navigationController?.popViewController(animated: true)
                }
                if let openpayment = self.openpayment{
                    self.navigationController?.pushViewController(openpayment, animated: true)
                }
            }))
           
            self.present(alertnew,animated: true,completion: nil)
        }
        }
                
         else {
         let alertdialog = UIAlertController(title: "No address found", message: "Please add the delivery address.", preferredStyle: .alert)
         alertdialog.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
         self.present(alertdialog,animated: true,completion: nil)
         }
        })
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

//Get Time
extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}



