//
//  ToDoModel.swift
//  ToDoApp
//
//  Created by Waseef Akhtar on 7/27/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoModel: Object {
    
    dynamic var title = ""
    dynamic var detailText = ""
    dynamic var timeStamp = ""
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
