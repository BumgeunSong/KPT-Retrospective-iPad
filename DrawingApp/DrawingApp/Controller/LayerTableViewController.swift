//
//  ShapeTableViewController.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/12.
//

import UIKit

class LayerTableViewController: UITableViewController {
    
    private var viewModels: [ViewModel] = []
    
    var didSelectRowClosure: ((Int) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isEditing = true
        NotificationCenter.default.addObserver(self, selector: #selector(didAddViewModel(_:)), name: Plane.Event.didAddViewModel, object: nil)
        tableView.allowsSelectionDuringEditing = true
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let cell = gesture.view else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let optionsVC = storyboard.instantiateViewController(
            withIdentifier: "popup")
        optionsVC.preferredContentSize = CGSize(width: 150, height: 200)
        
        optionsVC.modalPresentationStyle = .popover
        optionsVC.popoverPresentationController?.popoverLayoutMargins = .zero
        
        optionsVC.popoverPresentationController?.sourceView = cell
        self.present(optionsVC, animated: true)
    }
    
    @objc func didAddViewModel(_ notification: Notification) {
        guard let newViewModel = notification.userInfo?[Plane.InfoKey.added] as? ViewModel else { return }
        viewModels.append(newViewModel)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        let viewModel = viewModels[indexPath.row]
        
        config.text = viewModel.title
        config.imageProperties.tintColor = .black
        switch viewModel {
        case _ as Rectangle:
            config.image = UIImage(systemName: "rectangle")
        case _ as Photo:
            config.image = UIImage(systemName: "photo.artframe")
        case _ as Label:
            config.image = UIImage(systemName: "character.textbox")
        default:
            break
        }
        
        cell.contentConfiguration = config
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) is pressed")
        didSelectRowClosure?(indexPath.row)
    }
    
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // plane에게 메시지를 보내서 순서를 바꾼다.
        //        let moved = viewModels[fromIndexPath.row]
        viewModels.swapAt(fromIndexPath.row, to.row)
    }
    
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
