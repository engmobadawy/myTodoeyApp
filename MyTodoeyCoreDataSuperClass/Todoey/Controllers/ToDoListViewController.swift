import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mySearchBar: UISearchBar!

    var itemArray: [Item] = []
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext



    override func viewDidLoad() {
        super.viewDidLoad()
        mySearchBar.delegate = self
        
        // loadItems() // No need to call it here, it's called in didSet of selectedCategory
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let hexColor = selectedCategory?.cellColor {
            let nav = navigationController?.navigationBar
            nav?.backgroundColor = UIColor (hexString: hexColor )
            // 2. Set search bar's outer background (the thin border)
            mySearchBar.barTintColor = UIColor(hexString: hexColor)
            
            // 3. Make the search field (inside) white
            mySearchBar.searchTextField.backgroundColor = UIColor.white
          
            nav?.tintColor = ContrastColorOf(backgroundColor: UIColor(hexString: hexColor) , returnFlat: true)
            title = selectedCategory!.name
            
            nav?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor: UIColor(hexString: hexColor) , returnFlat: true)]
        }
       
    }

    @IBAction func pressedAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Task", message: "Type a task", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Enter task here"
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let textField = alert.textFields?.first
            let userInput = textField?.text ?? ""

            print("User entered: \(userInput)")

            let newItem = Item(context: self.context)
            newItem.title = userInput
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem) // Add to the array *before* saving
            self.saveItems()

        }

        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! SwipeTableViewCell
        
        cell.backgroundColor = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: CGFloat(indexPath.row)  / CGFloat(itemArray.count * 2 )
        )
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: cell.backgroundColor! ,returnFlat: true)
        let item = itemArray[indexPath.row] // Get the Item object
        cell.textLabel?.text = item.title // Access the 'title' property

        cell.accessoryType = item.done ? .checkmark : .none // Use the 'done' property

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].done.toggle() // Toggle the 'done' state
        saveItems() // Save context
       // Remove gray selection highlight

    }



    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        loadItems() // Reload items after saving to reflect changes
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let category = selectedCategory else {
            itemArray = []
            tableView.reloadData()
            return
        }

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", category.name!)
        var predicates = [categoryPredicate] // Start with an array of predicates

        if let additionalPredicate = predicate {
            predicates.append(additionalPredicate) // Add the search predicate if it exists
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates) // Create the compound predicate
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching items: \(error)")
        }
        tableView.reloadData()
    }
    override func updateModel(at indexPath: IndexPath) {
        let categoryToDelete = itemArray[indexPath.row]
               context.delete(categoryToDelete)
        itemArray.remove(at: indexPath.row)

               do {
                   try context.save()
               } catch {
                   print("Error saving after delete: \(error)")
               }
    }
}

extension ToDoListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            loadItems(with: request, predicate: titlePredicate) // Pass the predicate
        }
    }
    
}




//let itemToDelete = self.itemArray[indexPath.row]
//    self.context.delete(itemToDelete)
//
//    // 2. Remove from array
//    self.itemArray.remove(at: indexPath.row)
//
//    // 3. Save changes and reload table
////                self.saveItems()              // not making the datacore yet it is meke error
//do {
//    try self.context.save()
//} catch {
//    print("Error saving context: \(error)")
//}
