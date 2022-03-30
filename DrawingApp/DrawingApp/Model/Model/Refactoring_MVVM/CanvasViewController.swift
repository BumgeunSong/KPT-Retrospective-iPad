//
//  CanvasViewController.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import UIKit

protocol LayerViewDraggable {
    func setDragHandler(handler: ((UIView) -> ())?)
}

class CanvasViewController: UIViewController,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate {
    
    private var viewMap = [UIView: Layer]()
    
    private lazy var photoPicker: UIImagePickerController = {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        return photoPicker
    }()
    
    
    private var canvasView: UIView?
    
    var didMoveTemporaryView: ((UIView) -> ())?
    
    let canvasViewModel = CanvasViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
        setCanvasView()
        setUpTapRecognizer()
        
    }
    
    private func bind() {
        // Bind ViewModel
        canvasViewModel.newView.bind { [weak self] config in
            guard let config = config else { return }
            
            if let config = config as? RectangleConfiguration {
                let newView = UIView(frame: config.frame)
                newView.alpha = config.cgAlpha
                newView.backgroundColor = config.backgroundColor
                self?.setupPanRecognizer(newView)
                self?.canvasView?.addSubview(newView)
            }
        }
        
//        canvasViewModel.newSelectedView.bind { [weak self] view in
//            guard let view = view else { return }
//            self?.changeBorder(view)
//        }
        
        canvasViewModel.unselectedView.bind { [weak self] view in
            guard let view = view else { return }
            self?.clearBorder(view)
        }
        
    }
    
    private func setCanvasView() {
        let canvasView = UIView()
        self.canvasView = canvasView
        
        // CanvasView should be set behind of existing subviews, in front of KPT layouts
        view.insertSubview(canvasView, at: 1)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

// MARK: - Use case: Launch App

extension CanvasViewController {
    
    private func setUpTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        canvasView?.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: canvasView)
        let tappedPoint = Point(x: location.x, y: location.y)
        canvasViewModel.select(on: tappedPoint)
    }
}

// MARK: - Use Case: Touch Rectangle button (Input) & Add New Rectangle (Output)

extension CanvasViewController {
    
    @IBAction func didTouchRectangleButton(_ sender: UIButton) {
        canvasViewModel.add(of: Rectangle.self)
    }

    @IBAction func didTouchPhotoButton(_ sender: UIButton) {
        present(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.pngData() else { return }
        
        canvasViewModel.add(of: Photo.self, imageData: imageData)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Use Case: Touch label button (Input) & Add New Label (Output)

extension CanvasViewController {
    @IBAction func didTouchLabelButton(_ sender: UIButton) {
        canvasViewModel.add(of: Label.self)
    }
}

extension CanvasViewController {
    @IBAction func didTouchPostItButton(_ sender: UIButton) {
        canvasViewModel.add(of: PostIt.self)
    }
}

// MARK: - Use Case: Tap CanvasView (Input) & Select Layer (Output)

extension CanvasViewController {
    private func changeBorder(_ view: UIView) {
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func clearBorder(_ view: UIView) {
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
    }
}


//// MARK: - Use Case: Change Color (Output)
//
//extension CanvasViewController {
//
//    @objc func didChangeColor(_ notification: Notification) {
//        guard let selected = plane.selected,
//              let newColor = notification.userInfo?[Plane.InfoKey.changed] as? Color else { return }
//        let mutatedUIView = search(for: selected)
//        mutatedUIView?.backgroundColor = UIColor(with: newColor)
//    }
//}
//
//// MARK: - Use Case: Change Alpha (Output)
//
//extension CanvasViewController {
//
//    @objc func didChangeAlpha(_ notification: Notification) {
//        guard let selected = plane.selected,
//              let newAlpha = notification.userInfo?[Plane.InfoKey.changed] as? Alpha else { return }
//        let mutatedUIView = search(for: selected)
//        mutatedUIView?.alpha = CGFloat(with: newAlpha)
//    }
//}
//
//// MARK: - Use Case: Change origin (Output)
//
//extension CanvasViewController {
//
//    @objc func didChangeOrigin(_ notification: Notification) {
//        guard let mutated = notification.userInfo?[Plane.InfoKey.changed] as? Layer else { return }
//        let mutatedCavnasView = search(for: mutated)
//        mutatedCavnasView?.frame.origin = CGPoint(with: mutated.origin)
//    }
//}
//
//// MARK: - Use Case: Change size (Output)
//
//extension CanvasViewController {
//
//    @objc func didChangeSize(_ notification: Notification) {
//        guard let mutated = notification.userInfo?[Plane.InfoKey.changed] as? Layer else { return }
//        let mutatedUIView = search(for: mutated)
//        mutatedUIView?.frame.size = CGSize(with: mutated.size)
//    }
//}
//
//// MARK: - Use Case: Change text (Output)
//
//extension CanvasViewController {
//
//    @objc func didChangeText(_ notification: Notification) {
//        guard let selected = plane.selected,
//              let textMutableView = search(for: selected) as? TextMutable,
//              let newText = notification.userInfo?[Plane.InfoKey.changed] as? String else { return }
//        textMutableView.set(to: newText)
//
//        guard let mutatedUIView = textMutableView as? UILabel else { return }
//        resizeToFit(selected, for: mutatedUIView)
//    }
//}
//
// MARK: - Use Case: Drag layer (Input) & Change origin (Output)

extension CanvasViewController {

    private func setupPanRecognizer(_ canvasView: UIView) {
//        let pan = UIPanGestureRecognizer(target: self, action: #selector())
        canvasView.isUserInteractionEnabled = true
//        canvasView.addGestureRecognizer(pan)
    }
//
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        startPan(gesture)
//        drag(gesture)
//        endPan(gesture)
//    }
//
//    private func startPan(_ gesture: UIPanGestureRecognizer) {
//        guard let gestureView = gesture.view,
//              gesture.state == .began else { return }
//
//        guard let temporaryView = gestureView.copy() as? UIView else { return }
//
//        self.temporaryView = temporaryView
//        canvasView?.addSubview(temporaryView)
//    }
//
//    private func drag(_ gesture: UIPanGestureRecognizer) {
//        guard let temporaryView = temporaryView else { return }
//
//        let translation = gesture.translation(in: view)
//        temporaryView.center = CGPoint(
//            x: temporaryView.center.x + translation.x,
//            y: temporaryView.center.y + translation.y
//        )
//        gesture.setTranslation(.zero, in: view)
//        didMoveTemporaryView?(temporaryView)
//    }
//
//    private func endPan(_ gesture: UIPanGestureRecognizer) {
//        guard let gestureView = gesture.view,
//              let gestureLayer = viewMap[gestureView],
//              let temporaryView = temporaryView,
//              gesture.state == .ended else { return }
//
//        let lastOrigin = Point(x: temporaryView.frame.origin.x,
//                               y: temporaryView.frame.origin.y)
//
//        plane.change(layer: gestureLayer, toOrigin: lastOrigin)
//        temporaryView.removeFromSuperview()
//    }

    private func search(for view: UIView) -> Layer? {
        return viewMap[view]
    }
}
//
//// MARK: - Use Case: Reorder Layers via tableView cell (Input) & Reorder LayerViews in view hierachy (Ouput)
//
//extension CanvasViewController {
//
//    func setReorderHandler(to layerReorderable: LayerReoderable) {
//
//        layerReorderable.setReorderHandler { [weak self] from, to in
//            self?.plane.reorderLayer(fromIndex: from, toIndex: to)
//        }
//
//        layerReorderable.setReorderCommandHandler { [weak self] layer, command in
//            self?.plane.reorderLayer(layer, to: command)
//        }
//    }
//
//    @objc func didReorderLayer(_ notification: Notification) {
//        guard let reorderedLayer = notification.userInfo?[Plane.InfoKey.changed] as? Layer,
//              let layerView = layerMap[reorderedLayer],
//              let to = notification.userInfo?[Plane.InfoKey.toIndex] as? Int else {
//                  return
//              }
//        canvasView?.insertSubview(layerView, at: to)
//    }
//}
//
//// MARK: - Use Case: Select Layer via tableView cell (Input)
//
//extension CanvasViewController {
//
//    private func setSelectHandler(to layerSelectable: LayerSelectable) {
//        layerSelectable.setSelectHandler { [weak self] selected in
//            self?.plane.select(layer: selected)
//        }
//    }
//}
