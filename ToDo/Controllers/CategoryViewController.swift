//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Hind Hesham on 04/04/2023.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var categoryList = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        loadCategories()
        
    }

    // MARK: - Table View Data Source Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //calling parent swipe cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let categoryItem = categoryList[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = categoryItem.name
        cell.contentConfiguration = content
        cell.backgroundColor = UIColor(hexString: categoryItem.colour ?? "1D9BF6")
        
        return cell
    }
    
    //MARK: - Table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            
            destinationVC.selectedCategory = categoryList[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    func saveCategory(){
        do{
            try context.save()
        } catch{
            print("Error while saveing new category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do{
           categoryList = try context.fetch(request)
        } catch{
            print("Error while load categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        context.delete(categoryList[indexPath.row])
        categoryList.remove(at: indexPath.row)

        do{
            try context.save()
        } catch{
            print("Error while deleteing category \(error)")
        }
    }

    
    //MARK: - Add New Category
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDo Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if(textField.text != ""){
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text
                newCategory.colour = UIColor.randomFlat().hexValue()
                self.categoryList.append(newCategory)
                self.saveCategory()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
