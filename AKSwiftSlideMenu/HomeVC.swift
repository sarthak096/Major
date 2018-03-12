//
//  HomeVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class HomeVC: BaseViewController {

    @IBOutlet var scanButton: UIButton!
    var barcodeScanner: ScanNGoViewController?
    public var appDone: ((String) -> ())?
    
    var pageImages: NSArray!
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        barcodeScanner = self.storyboard!.instantiateViewController(withIdentifier: "ScanNGoViewControllerScene") as?ScanNGoViewController
        scanButton.layer.cornerRadius = 0.2 * scanButton.bounds.size.width
        scanButton.clipsToBounds = true
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
