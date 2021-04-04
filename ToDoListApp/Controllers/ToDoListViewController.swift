//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Masato Takamura on 2021/03/30.
//

import UIKit
import CoreData


class ToDoListViewController: UITableViewController {
    
    //itemの配列を用意
    var itemArray = [Item]()
    
    //親カテゴリー
    var selectedCategory: Category? {
        //値が入ったときにitemをロード
        didSet {
            loadItems()
        }
    }
    
    //NSPersistentContainer内にラッピングされたNSManagedObjectContextをAppDelegate経由でオブジェクト化
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //保存場所をプリント
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
   
    }


    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //三項演算子
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //チェック状態を反転させる
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //doneアトリビュートが変更されたので保存
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //アラート表示
        let alert = UIAlertController(title: "新しいToDoを追加します", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "追加", style: .default) { [weak self] (action) in
            
            //NSManagedObjectContextをオブジェクト化
            let newItem = Item(context: self!.context)
            //各プロパティを設定
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self?.selectedCategory
            //itemを追加
            self?.itemArray.append(newItem)
            //データを保存
            self?.saveItems()
            
        }
        //アラートにtextFieldを追加
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "追加項目を入力してください。"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        //フェッチリクエストに絞り込み条件をつけるためにprediateプロパティを設定する
        //%@: selectedCategory!.name!を埋め込む
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //追加の検索条件 (predicate)
        if let additionalPredicate = predicate {
            //複合predicate
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
       
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    
}

//MARK: - UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //CONTAINS[cd] [c]: 大文字小文字の区別はしない、[d]: 発音記号の有無は同一文字として扱う
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //調べるときのソート (何順でソートするか)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
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

