//
//  MainViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import BWWalkthrough

class MainViewController:UIViewController,BWWalkthroughViewControllerDelegate {
    
    var needWalkthrough:Bool = true
    var walkthrough:BWWalkthroughViewController!
    var newView: HomeVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!UserDefaults.standard.bool(forKey: "ad")){
            if needWalkthrough{
            self.presentWalkthrough()
            UserDefaults.standard.set(true, forKey: "ad")
            UserDefaults.standard.synchronize();
            }
        }
        else{
            self.newView?.appDone = { (barcode: String) in
                _ = self.navigationController?.popViewController(animated: true)
            }
            if let newView = self.newView{
                self.navigationController?.pushViewController(newView, animated: true)
            }
            }
    }
    
    @IBAction func presentWalkthrough(){
        
        let stb = UIStoryboard(name: "Main", bundle: nil)
        walkthrough = stb.instantiateViewController(withIdentifier: "container") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewController(withIdentifier: "page_1")
        let page_two = stb.instantiateViewController(withIdentifier: "page_2")
        let page_three = stb.instantiateViewController(withIdentifier: "page_3")
        let page_four = stb.instantiateViewController(withIdentifier: "page_4")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthrough.add(viewController:page_four)
        
        self.present(walkthrough, animated: true) {
            ()->() in
            self.needWalkthrough = false
        }
    }
}


extension MainViewController{
    
    func walkthroughCloseButtonPressed() {
        print("close")
        self.newView?.appDone = { (barcode: String) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        if let newView = self.newView{
            self.navigationController?.pushViewController(newView, animated: true)
        }
    }
    func walkthroughPageDidChange(pageNumber: Int) {
        if (self.walkthrough.numberOfPages - 1) == pageNumber{
            self.walkthrough.closeButton?.isHidden = false
        }else{
            self.walkthrough.closeButton?.isHidden = true
        }
    }
    
}
