import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework


class CategoryViewControllerTableViewController: SwipeTableViewController {

    var myCategoryVariable : [Category] = []
    var cellColor : [String] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // ✅ Replaces FileManager; uses Core Data context


    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        loadCategory()

    }
    override func viewWillAppear(_ animated: Bool) {
        let nav = navigationController?.navigationBar
        nav?.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Catogery", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter catogery here"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let textField = alert.textFields?.first
            let userInput = textField?.text ?? ""
            
            print("User entered: \(userInput)")
            
            let newCategory = Category(context: self.context)
            newCategory.name = userInput
            newCategory.cellColor = UIColor.randomFlat().hexValue()
            
            
            
            self.myCategoryVariable.append(newCategory)
            self.saveCategory()
            
        }
        
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCategoryVariable.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        // 1. Retrieve the hex color string from the current Category object
            if let hexColorString = myCategoryVariable[indexPath.row].cellColor {
                // 2. Use the hex color string to set the background color
                cell.backgroundColor = UIColor(hexString: hexColorString)
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor: UIColor(hexString: hexColorString), returnFlat: true)
            } else {
                // Handle the case where cellColor might be nil (e.g., for older data)
                cell.backgroundColor = .white // Or some default color
            }
        
      
        
        cell.textLabel?.text = myCategoryVariable[indexPath.row].name
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItem", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToItem" {
                if let destinationVC = segue.destination as? ToDoListViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let selectedCategory = myCategoryVariable[indexPath.row]
                        destinationVC.selectedCategory = selectedCategory
                    }
                }
            }
        }
    
    
    
    
 // MARK: - Data Manipulation
    
    func saveCategory() {
        
        do {
            try context.save()
            
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()

    }
    
    
    func loadCategory(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
         /*  let request: NSFetchRequest<Item> = Item.fetchRequest()*/ // ✅ Create fetch request for Core Data
           do {
               myCategoryVariable = try context.fetch(request) // ✅ Fetching from Core Data
           } catch {
               print("Error fetching data from context: \(error)") // ✅ Error for fetch
           }
       }
    override func updateModel(at indexPath: IndexPath) {
           let categoryToDelete = myCategoryVariable[indexPath.row]
           context.delete(categoryToDelete)
           myCategoryVariable.remove(at: indexPath.row)

           do {
               try context.save()
           } catch {
               print("Error saving after delete: \(error)")
           }
       }
    
    
}

