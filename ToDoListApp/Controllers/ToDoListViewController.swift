//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Masato Takamura on 2021/03/30.
//

import UIKit
import RealmSwift
import ChameleonFramework


class ToDoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    //itemの配列を用意
    var toDoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //親カテゴリー
    var selectedCategory: Category? {
        //値が入ったときにitemをロード
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        //保存場所をプリント
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let colorHex = selectedCategory?.color {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                view.backgroundColor = navBarColor
                searchBar.barTintColor = navBarColor
            }
            
           
        }
        
        
        
    }


    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            //三項演算子
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "アイテムが追加されていません。"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Delete Data From Swipe
    override func updateDataModel(at indexPath: IndexPath) {
        super.updateDataModel(at: indexPath)
        
        if let itemsForDeletion = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemsForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
        
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //アラート表示
        let alert = UIAlertController(title: "新しいToDoを追加します", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "追加", style: .default) { [weak self] (action) in
            
            if let currentCategory = self?.selectedCategory {
                do {
                    try self?.realm.write {
                        
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        
                        self?.realm.add(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self?.tableView.reloadData()
            
        }
        //アラートにtextFieldを追加
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "追加項目を入力してください。"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    
    
}

//MARK: - UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //文字が0になったら
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

