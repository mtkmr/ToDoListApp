//
//  Item.swift
//  ToDoListApp
//
//  Created by Masato Takamura on 2021/04/04.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    //List<Item>の逆の関係を示しているだけ
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
