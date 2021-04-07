//
//  Category.swift
//  ToDoListApp
//
//  Created by Masato Takamura on 2021/04/04.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
    
}
