//
//  MyCustomPageViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//


import UIKit
import BWWalkthrough

class MyCustomPageViewController: BWWalkthroughPageViewController {
    
   // @IBOutlet var backgroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // view.layer.zPosition = -1000
      //  view.layer.isDoubleSided = false
       // self.backgroundView.layer.masksToBounds = false
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func walkthroughDidScroll(to position: CGFloat, offset: CGFloat) {
        var tr = CATransform3DIdentity
        tr.m34 = -1/1000.0
      //  view.layer.transform = CATransform3DRotate(tr, CGFloat(M_PI)  * (1.0 - offset), 0.5,1, 0.2)
    }
}

