//
//  GlobalVariables.swift
//  AKSwiftSlideMenu
//
//  Created by i on 4/5/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit

class GlobalVariables{
    public var totalprice: Int = 0
    public var tempprice : Int = 0
    public var orderarray : [String] = []
    public var orderscount : Int = 0
    public var item : String = ""
    public var modeofpayment: String = ""
    public var orderlist : [String] = []
    public var tempquant : Int  = 0
    public var ordercode : String = ""
    class var sharedManager: GlobalVariables{
        struct Static{
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
}
