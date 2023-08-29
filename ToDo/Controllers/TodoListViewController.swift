//
//  ViewController.swift
//  ToDo
//
//  Created by Hind Hesham on 28/03/2023.
//

import UIKit
import CoreData
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var todoItemsArray = [ToDoItem]()
    var selectedCategory : Category? {
        didSet{
            loadToDoItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.rowHeight = 80.0
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let todoItem = todoItemsArray[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = todoItem.title
        
        if let colour = UIColor.flatMagenta().darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItemsArray.count)){
            
            cell.backgroundColor = colour
            content.textProperties.color = ContrastColorOf(colour, returnFlat: true)
        }
        
        cell.contentConfiguration = content
        
        //ternary operator
        cell.accessoryType = todoItem.done ? .checkmark : .none

        return cell
        
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        todoItemsArray[indexPath.row].done.toggle()
        saveToDoItem()
        
        // to change selected cell animation
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // what will happen when pressed
            if(textField.text != ""){
                let newItem = ToDoItem(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.todoItemsArray.append(newItem)
                self.saveToDoItem()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveToDoItem(){
        
        do{
            try context.save()
            
        } catch{
            print("Error while saveing todo item \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadToDoItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHeS %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
        
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            
        }else{
            
            request.predicate = categoryPredicate
        }
        
        do{
            todoItemsArray = try context.fetch(request)
            
        } catch{
            
            print("Error while load items \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(todoItemsArray[indexPath.row])
        todoItemsArray.remove(at: indexPath.row)
        do{
            try context.save()
            
        } catch{
            print("Error while deleteing todo item \(error)")
        }
    }
    
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[c] %@", searchBar.text!)
        request.predicate = predicate
        request.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true) ]
        
        loadToDoItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if(searchBar.text!.count == 0){
            loadToDoItems()
            DispatchQueue.main.async {
                // back to original list
                searchBar.resignFirstResponder()
            }
        }

    }
}

