//
//  HomeVC.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import ChameleonFramework

// HomeViewController to scan the barcode
class HomeVC: BaseViewController {

    //Outlets and variables
    @IBOutlet var scanButton: UIButton!
    var barcodeScanner: ScanNGoViewController?
    public var appDone: ((String) -> ())?
    var pageImages: NSArray!
    var pageViewController: UIPageViewController!
    public var openedHome: ((String) -> ())?
    
    //Load the viewcontroller
    override func viewDidLoad() {
        super.viewDidLoad()
        //add menu btn
        addSlideMenuButton()
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        barcodeScanner = self.storyboard!.instantiateViewController(withIdentifier: "ScanNGoViewControllerScene") as?ScanNGoViewController
        //Make round Btn
        scanButton.layer.cornerRadius = 0.2 * scanButton.bounds.size.width
        scanButton.clipsToBounds = true
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to instantiate homeVC on Btn pressed
    @IBAction func clicked(_ sender: Any) {
        barcodeScanner?.barcodeScanned = { (barcode: String) in
            _ = self.navigationController?.popViewController(animated: true)
            print("Received following barcode: \(barcode)")
        }
        if let barcodeScanner = self.barcodeScanner{
            self.navigationController?.pushViewController(barcodeScanner, animated: true)
        }
    }
}
