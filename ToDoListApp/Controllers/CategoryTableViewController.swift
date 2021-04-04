//
//  CategoryTableViewController.swift
//  ToDoListApp
//
//  Created by Masato Takamura on 2021/04/01.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    //category配列を用意
    var categories = [Category]()
    
    //NSManagedObjectContextをオブジェクト化
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
    }
    
    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK - Data Manipulation Methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading category \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //アラート表示
        let alert = UIAlertController(title: "新しいCategoryを追加します", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "追加", style: .default) { [weak self] (action) in
            
            let newCategory = Category(context: self!.context)
            newCategory.name = textField.text!
            
            self?.categories.append(newCategory)
            
            self?.saveCategories()
            
        }
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "追加カテゴリーを入力してください。"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
}
