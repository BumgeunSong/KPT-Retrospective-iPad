//
//  LayerTableViewController.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/14.
//

import UIKit

protocol LayerReoderable {
    func setReorderHandler(handler: ((Int, Int) -> ())?)
    func setReorderCommandHandler(handler: ((Layer, Plane.reorderCommand) -> ())?)
}

protocol LayerFetchable {
    func setFetchLayerHandler(handler: ((Int) -> Layer?)?)
    func setFetchLayerCountHandler(handler: (() -> Int?)?)
}

protocol LayerSelectable {
    func setSelectHandler(handler: ((Layer?) -> ())?)
}

class LayerTableViewController: UITableViewController {
    
    enum identifier { static let cell = "LayerCell" }
    
    var didSelectRowHandler: ((Layer?) -> ())?
    
    var didMoveRowHandler: ((Int, Int) -> ())?
    var didCommandMoveHandler: ((Layer, Plane.reorderCommand) -> ())?
    
    var fetchLayer: ((Int) -> Layer?)?
    var fetchLayerCount: (() -> Int?)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        subscribePlaneNotification()
    }
    
    private func configureTableView() {
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    private func subscribePlaneNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didAddLayer(_:)), name: Plane.Event.didAddLayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReorderLayer(_:)), name: Plane.Event.didReorderLayer, object: nil)
    }
}

extension LayerTableViewController: LayerSelectable {
    func setSelectHandler(handler: ((Layer?) -> ())?) {
        self.didSelectRowHandler = handler
    }
}

extension LayerTableViewController: LayerReoderable {
    func setReorderHandler(handler: ((Int, Int) -> ())?) {
        self.didMoveRowHandler = handler
    }
    
    func setReorderCommandHandler(handler: ((Layer, Plane.reorderCommand) -> ())?) {
        self.didCommandMoveHandler = handler
    }
}

extension LayerTableViewController: LayerFetchable {
    func setFetchLayerHandler(handler: ((Int) -> Layer?)?) {
        self.fetchLayer = handler
    }
    func setFetchLayerCountHandler(handler: (() -> Int?)?) {
        self.fetchLayerCount = handler
    }
}

// MARK: - Table view data source

extension LayerTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchLayerCount?() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryBoardLayerCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        
        guard let layer = fetchLayer?(indexPath.row) else { return cell }
        config.text = layer.title
        
        guard let symbol = ViewFactory.createSymbol(from: layer) else { return cell }
        config.image = symbol
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

// MARK: - Use case: Add Layer
// MARK: [Output] Load table cell according to Layers (Output)

extension LayerTableViewController {
    
    @objc func didAddLayer(_ notification: Notification) {
        tableView.reloadData()
    }
}

// MARK: - Use case: Select Layer
// MARK: [Input] Touch table cell (input)

extension LayerTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedLayer = fetchLayer?(indexPath.row) else { return }
        didSelectRowHandler?(selectedLayer)
    }
}

// MARK: - Use case: Reorder Layer
// MARK: [Input] Move Row with drag & Long press menu
// MARK: [Output] Update table cell

extension LayerTableViewController {
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        didMoveRowHandler?(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let layer = fetchLayer?(indexPath.row) else { return nil }
        
        let sendToBack = UIAction(title: "맨 뒤로 보내기", image: UIImage(systemName: "arrow.uturn.backward.square"), identifier: nil, discoverabilityTitle: nil) { _ in
            self.didCommandMoveHandler?(layer, .sendToBack)
        }
        
        let bringToFront = UIAction(title: "맨 앞으로 가져오기", image: UIImage(systemName: "arrow.uturn.forward.square"), identifier: nil, discoverabilityTitle: nil) { _ in
            self.didCommandMoveHandler?(layer, .bringToFront)
        }
        
        let sendBackward = UIAction(title: "뒤로 보내기", image: UIImage(systemName: "arrow.backward.square"), identifier: nil, discoverabilityTitle: nil) { _ in
            self.didCommandMoveHandler?(layer, .sendBackward)
        }
        
        let bringForward = UIAction(title: "앞으로 가져오기", image: UIImage(systemName: "arrow.forward.square"), identifier: nil, discoverabilityTitle: nil) { _ in
            self.didCommandMoveHandler?(layer, .bringForward)
        }
        
        let menu = UIMenu(title: "Arrange Layer", image: nil, identifier: nil, options: .displayInline, children: [sendToBack, bringToFront, sendBackward, bringForward])
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return menu
        }
    }
    
    @objc func didReorderLayer(_ notification: Notification) {
        guard let from = notification.userInfo?[Plane.InfoKey.fromIndex] as? Int,
              let to = notification.userInfo?[Plane.InfoKey.toIndex] as? Int else { return }
        tableView.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
    }
}
