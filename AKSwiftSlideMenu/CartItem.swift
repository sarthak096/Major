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
    var completed: Bool
    
    init(name: String, completed: Bool, key: String = ""){
        self.key = key
        self.name = name
        self.completed = completed
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any{
        return[
            "name": name, "completed": completed]
    }
}

