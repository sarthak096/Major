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
import Stripe

class ListTableViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource, PayPalPaymentDelegate,STPAddCardViewControllerDelegate,CardIOPaymentViewControllerDelegate{
    
    //Functions for the Stripe Payment
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    //Functions for the PayPal Payment
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
         navigationController?.popViewController(animated: true)
        
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        if (true){
                completion(nil)
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
                //self.ref.child("users").child(self.id).child("orders").child(time).childByAutoId().setValue(stre)
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
                let alertController = UIAlertController(title: "Congrats", message: "Your payment was successful!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
            
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
                GlobalVariables.sharedManager.modeofpayment = "Online"
                self.clearCart()
        }// 2
        else{
            } 
        }

    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
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
            //self.ref.child("users").child(self.id).child("orders").child(time).childByAutoId().setValue(stre)
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
        GlobalVariables.sharedManager.modeofpayment = "Online"
        self.clearCart()
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
        })
    }
    
    
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
    @IBOutlet weak var totalLabel: UILabel!
    var environment: String = PayPalEnvironmentNoNetwork{
        willSet(newEnvironment)
        {
            if (newEnvironment != environment){
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    var payPalConfig = PayPalConfiguration()
    
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
        
        //Set up PayPalCongif
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Scan N Go"  //Give your company name here.
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        //This is the language in which your paypal sdk will be shown to users.
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        //Here you can set the shipping address. You can choose either the address associated with PayPal account or different address. We'll use .both here.
        
        payPalConfig.payPalShippingAddressOption = .both;
        CardIOUtilities.preload()
    }
    
    //Reload TableView
    @objc func loadList(){
        self.isEditing = !self.isEditing
       self.tableView.reloadData()
    }
    
    //Create CoreData Object and FetchRequest
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
         GlobalVariables.sharedManager.totalprice = 0
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        totalLabel.text = "$" + String(GlobalVariables.sharedManager.totalprice)
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
        let new1 : String = (cartname.value(forKey: "itemname") as? String)!
        let str1 = String(new1)
        let intstr = Int(str)
        
        ref.child("Database").child(str1).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value as! [String: Any]
            let qprice = userDict["Price"] as! String
            let qdesc = userDict["Description"] as! String
            let intprice = Int(qprice)
            let finalprice  = intstr! * intprice!
            let price = String(finalprice)
            let totalprice  = Int(finalprice)
            GlobalVariables.sharedManager.tempprice = totalprice
            cell.textLabel?.text = "Item : " + qdesc 
            cell.detailTextLabel?.text = "Quantity : " + str + "    ,   Price : $" + price
            GlobalVariables.sharedManager.totalprice = GlobalVariables.sharedManager.totalprice + GlobalVariables.sharedManager.tempprice
            print(GlobalVariables.sharedManager.totalprice)
        })
        
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
            let new1 : String = (objectdelete.value(forKey: "itemname") as? String)!
            let new: Int = (objectdelete.value(forKey: "itemquantity") as? Int)!
            let str = String(new)
            let intstr = Int(str)
            pcart.remove(at: indexPath.row)
            print("REMOVE")
            print(GlobalVariables.sharedManager.totalprice)
            ref.child("Database").child(new1).observeSingleEvent(of: .value, with: { DataSnapshot in
                if !DataSnapshot.exists(){
                    return
                }
                let userDict = DataSnapshot.value as! [String: Any]
                let qprice = userDict["Price"] as! String
                let qdesc = userDict["Description"] as! String
                let intprice = Int(qprice)
                let finalprice  = intstr! * intprice!
                let price = String(finalprice)
                let totalprice  = Int(finalprice)
                GlobalVariables.sharedManager.tempprice = totalprice
                GlobalVariables.sharedManager.totalprice = GlobalVariables.sharedManager.totalprice - GlobalVariables.sharedManager.tempprice
                print(GlobalVariables.sharedManager.totalprice)
                self.totalLabel.text = "$" + String(GlobalVariables.sharedManager.totalprice)
            })
            
            managedContext.delete(objectdelete)
            do{
                try appDelegate.saveContext()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error as NSError{
            }
            self.tableView.reloadData()
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
            if self.pcart.count <= 0 {
                self.totalLabel.text = "0"}
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
                //Payemnt options
                let alertpayment = UIAlertController(title: "Payment", message: "Select the payment method.", preferredStyle: .alert)
                alertpayment.addAction(UIAlertAction(title: "Cash on delivery", style: .default, handler: { (alertAction) -> Void in
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
                        //self.ref.child("users").child(self.id).child("orders").child(time).childByAutoId().setValue(stre)
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
                    GlobalVariables.sharedManager.modeofpayment = "Cash"
                    self.clearCart()
                }))
                alertpayment.addAction(UIAlertAction(title: "PayPal", style: .default, handler: { (alertAction) -> Void in
                    let item1 = PayPalItem(name: "Brewit-tshirt", withQuantity: 2, withPrice: NSDecimalNumber(string: "84.99"), withCurrency: "USD", withSku: "BREWIT-0011")
                    let item2 = PayPalItem(name: "Free Brewit cards", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "BREWIT-0012")
                    let item3 = PayPalItem(name: "Brewit-cup", withQuantity: 1, withPrice: NSDecimalNumber(string: "37.99"), withCurrency: "USD", withSku: "BREWIT-0091")
                    
                    let items = [item1, item2, item3]
                    //let subtotal = PayPalItem.totalPrice(forItems: items) //This is the total price of all the items
                    let amt = NSDecimalNumber(integerLiteral: GlobalVariables.sharedManager.totalprice)
                    print(amt)
                    // Optional: include payment details
                    let shipping = NSDecimalNumber(string: "5")
                    let tax = NSDecimalNumber(string: "2")
                    let paymentDetails = PayPalPaymentDetails(subtotal: amt, withShipping: shipping, withTax: tax)
                    
                    let total = amt.adding(shipping).adding(tax) //This is the total price including shipping and tax
                    
                    let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Total", intent: .sale)
                    
                    //payment.items = items
                    payment.paymentDetails = paymentDetails
                    
                    if (payment.processable) {
                        let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.payPalConfig, delegate: self)
                        self.present(paymentViewController!, animated: true, completion: nil)
                    }
                    else {
                        // This particular payment will always be processable. If, for
                        // example, the amount was negative or the shortDescription was
                        // empty, this payment wouldn't be processable, and you'd want
                        // to handle that here.
                        print("Payment not processalbe: \(payment)")
                    }
                    
                }))
                alertpayment.addAction(UIAlertAction(title: "Other(Card)", style: .default, handler: { (alertAction) -> Void in
                    let addCardViewController = STPAddCardViewController()
                    addCardViewController.delegate = self
                    self.navigationController?.pushViewController(addCardViewController, animated: true)
                }))
                
                alertpayment.addAction(UIAlertAction(title: "Cancel ", style: .destructive, handler: nil))
                self.present(alertpayment,animated: true,completion: nil)
                
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



