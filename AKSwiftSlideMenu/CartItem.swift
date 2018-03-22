//
//  CartItem.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct CartItem {
    let key: String
    let name: String
    let ref: DatabaseReference?
   
    
    init(name: String, completed: Bool, key: String = ""){
        self.key = key
        self.name = name
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["item"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any{
        return[
            "name": name]
    }
}

