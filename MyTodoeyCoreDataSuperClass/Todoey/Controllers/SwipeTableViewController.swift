import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController ,SwipeTableViewCellDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
            
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
              }
        
      
        // customize the action appearance
        deleteAction.image = UIImage(named: "Trash-Icon")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
            // Override in child classes
        }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
    }
    
    
    

}
