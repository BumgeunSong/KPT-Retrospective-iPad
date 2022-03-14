//
//  CanvasViewController.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import UIKit

class CanvasViewController: UIViewController,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate {
    
    private var plane = Plane()
    private var viewModelMap = [ViewModel: UIView]()
    private var viewMap = [UIView: ViewModel]()
    private let photoPicker = UIImagePickerController()
    private var temporaryView: UIView?
    private var layerTableVC: LayerTableViewController?
    
    enum Event {
        static let isDragging = Notification.Name("drag")
    }
    
    enum InfoKey {
        static let origin = "origin"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observePlane()
        observePanel()
        
        setUpInitialModels()
        setUpTapRecognizer()
        
        photoPicker.delegate = self
        
        guard let layerTableVC = splitViewController?.viewController(for: .supplementary) as? LayerTableViewController else {
            return
        }
        self.layerTableVC = layerTableVC
        layerTableVC.didSelectRowClosure = { index in
            self.plane.select(at: index)
        }
    }
}


// MARK: - Use case: Launch App

extension CanvasViewController {
    
    private func observePlane() {
        NotificationCenter.default.addObserver(self, selector: #selector(didAddViewModel(_:)), name: Plane.Event.didAddViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectViewModel(_:)), name: Plane.Event.didSelectViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetColor(_:)), name: Plane.Event.didSetColor, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetAlpha(_:)), name: Plane.Event.didSetAlpha, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetOrigin(_:)), name: Plane.Event.didSetOrigin, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetSize(_:)), name: Plane.Event.didSetSize, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetText(_:)), name: Plane.Event.didSetText, object: plane)
    }
    
    private func observePanel() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeSlider(_:)), name: PanelViewController.Event.didChangeSlider, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTouchColorButton(_:)), name: PanelViewController.Event.didTouchColorButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTouchOriginStepper(_:)), name: PanelViewController.Event.didTouchOriginStepper, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTouchSizeStepper(_:)), name: PanelViewController.Event.didTouchSizeStepper, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEditTextField(_:)), name: PanelViewController.Event.didEditTextField, object: nil)
    }
    
    private func setUpRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap)
    }
    
    private func setUpInitialModels() {
        (0..<4).forEach { _ in plane.addRectangle() }
    }
    
    private func setUpTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap)
    }
}



// MARK: - Use Case: Add New Rectangle

extension CanvasViewController {
    
    @IBAction func didTouchRectangleButton(_ sender: UIButton) {
        plane.addRectangle()
    }
    
    @objc func didAddViewModel(_ notification: Notification) {
        guard let newViewModel = notification.userInfo?[Plane.InfoKey.added] as? ViewModel else { return }
        guard let newView = ViewFactory.create(from: newViewModel) else { return }

        map(newView, to: newViewModel)

        if newView is UILabel { resizeToFit(newViewModel, for: newView) }

        view.addSubview(newView)
        setupPanRecognizer(newView)
    }
    
    private func createView(from viewModel: ViewModel) -> UIView? {
        return ViewFactory.create(from: viewModel)
    }
    
    private func map(_ view: UIView, to viewModel: ViewModel) {
        viewModelMap[viewModel] = view
        viewMap[view] = viewModel
    }
}

// MARK: - Use Case: Add New Photo

extension CanvasViewController {
    
    @IBAction func didTouchPhotoButton(_ sender: UIButton) {
        present(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.pngData() else { return }
        
        plane.addPhoto(data: imageData)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Use Case: Add New Label

extension CanvasViewController {
    @IBAction func didTouchLabelButton(_ sender: UIButton) {
        plane.addLabel()
    }
    
    // Set viewModel to fit intrinsic content size
    private func resizeToFit(_ viewModel: ViewModel, for view: UIView) {
        let fitSize = Size(width: view.intrinsicContentSize.width, height: view.intrinsicContentSize.height)
        plane.set(viewModel: viewModel, to: fitSize)
    }
}

// MARK: - Use Case: Select CanvasView

extension CanvasViewController {
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let tappedPoint = Point(x: location.x, y: location.y)
        plane.tap(on: tappedPoint)
    }
    
    @objc func didSelectViewModel(_ notification: Notification) {
        if let new = notification.userInfo?[Plane.InfoKey.selected] as? ViewModel {
            guard let newView = search(for: new) else { return }
            changeBorder(newView)
        }
        
        if let old = notification.userInfo?[Plane.InfoKey.unselected] as? ViewModel {
            guard let oldView = search(for: old) else { return }
            clearBorder(oldView)
        }
    }
    
    private func search(for viewModel: ViewModel) -> UIView? {
        return viewModelMap[viewModel]
    }
    
    private func changeBorder(_ view: UIView) {
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func clearBorder(_ view: UIView) {
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
    }
}

// MARK: - Use Case: Change CanvasView

extension CanvasViewController {
    
    
    
    @objc func didTouchColorButton(_ notification: Notification) {
        plane.setSelected()
    }
    
    @objc func didSetColor(_ notification: Notification) {
        guard let selected = plane.selected,
              let newColor = notification.userInfo?[Plane.InfoKey.set] as? Color else { return }
        let mutatedUIView = search(for: selected)
        mutatedUIView?.backgroundColor = UIColor(with: newColor)
    }
    
    @objc func didChangeSlider(_ notification: Notification) {
        guard let value = notification.userInfo?[PanelViewController.InfoKey.value] as? Float else { return }
        
        if let alpha = Alpha(value) {
            plane.setSelected(to: alpha)
        }
    }
    
    @objc func didSetAlpha(_ notification: Notification) {
        guard let selected = plane.selected,
              let newAlpha = notification.userInfo?[Plane.InfoKey.set] as? Alpha else { return }
        let mutatedUIView = search(for: selected)
        mutatedUIView?.alpha = CGFloat(with: newAlpha)
    }
    
    @objc func didTouchOriginStepper(_ notification: Notification) {
        guard let origin = notification.userInfo?[PanelViewController.InfoKey.origin] as? Point else { return }
        plane.setSelected(to: origin)
    }
    
    @objc func didSetOrigin(_ notification: Notification) {
        guard let mutated = notification.userInfo?[Plane.InfoKey.set] as? ViewModel else { return }
        let mutatedCavnasView = search(for: mutated)
        mutatedCavnasView?.frame.origin = CGPoint(with: mutated.origin)
    }
    
    @objc func didTouchSizeStepper(_ notification: Notification) {
        guard let size = notification.userInfo?[PanelViewController.InfoKey.size] as? Size else { return }
        plane.setSelected(to: size)
    }
    
    @objc func didSetSize(_ notification: Notification) {
        guard let mutated = notification.userInfo?[Plane.InfoKey.set] as? ViewModel else { return }
        let mutatedUIView = search(for: mutated)
        mutatedUIView?.frame.size = CGSize(with: mutated.size)
    }
    
    @objc func didEditTextField(_ notification: Notification) {
        guard let text = notification.userInfo?[PanelViewController.InfoKey.text] as? String else { return }
        plane.setSelected(to: text)
    }
    
    @objc func didSetText(_ notification: Notification) {
        guard let selected = plane.selected,
              let mutatedUIView = search(for: selected) as? UILabel,
              let newText = notification.userInfo?[Plane.InfoKey.set] as? String else { return }
        mutatedUIView.text = newText
        resizeToFit(selected, for: mutatedUIView)
    }
}

// MARK: - Use Case: Drag CanvasView

extension CanvasViewController {
    
    private func setupPanRecognizer(_ canvasView: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        canvasView.isUserInteractionEnabled = true
        canvasView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        startPan(gesture)
        drag(gesture)
        endPan(gesture)
    }
    
    private func startPan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view,
              gesture.state == .began else { return }
        
        let temporaryView = ViewFactory.clone(gestureView)
        self.temporaryView = temporaryView
        view.addSubview(temporaryView)
    }
    
    private func drag(_ gesture: UIPanGestureRecognizer) {
        guard let temporaryView = temporaryView else { return }
        
        let translation = gesture.translation(in: view)
        temporaryView.center = CGPoint(
            x: temporaryView.center.x + translation.x,
            y: temporaryView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: view)
        
        displayTemporaryOrigin(temporaryView)
    }
    
    private func displayTemporaryOrigin(_ temporaryView: UIView) {
        let temporaryOrigin = Point(x: temporaryView.frame.origin.x, y: temporaryView.frame.origin.y)
        NotificationCenter.default.post(name: CanvasViewController.Event.isDragging, object: self, userInfo: [CanvasViewController.InfoKey.origin: temporaryOrigin])
    }
    
    private func endPan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view,
              let gestureViewModel = viewMap[gestureView],
              let temporaryView = temporaryView,
              gesture.state == .ended else { return }
        
        let lastOrigin = Point(x: temporaryView.frame.origin.x,
                               y: temporaryView.frame.origin.y)
        
        plane.set(viewModel: gestureViewModel, to: lastOrigin)
        temporaryView.removeFromSuperview()
    }
    
    private func search(for view: UIView) -> ViewModel? {
        return viewMap[view]
    }
}


//
//class ObservedClass: NSObject {
//    @objc dynamic var value: CGFloat = 0
//}
//
//class Observer {
//    var kvoToken: NSKeyValueObservation?
//
//    func observe(object: ObservedClass) {
//        kvoToken = object.observe(\.value, options: .new, changeHandler: { object, change in
//            guard let value = change.newValue else { return }
//            print("New Value: \(value)")
//        })
//    }
//
//    deinit {
//        kvoToken?.invalidate()
//    }
//}
//
//typealias PizzaClosure = (String) -> Void
//
//class Pizzaiolo {
//    private var completion: PizzaClosure?
//
//    func makePizza(completion: @escaping PizzaClosure) {
//        self.completion = completion
//        // cooking
//
//    }
//
//    private func onPizzaIsReady(pizza: String) {
//        self.completion?(pizza)
//        self.completion = nil
//    }
//}
//
//class Customer {
//    func askToMakePizza(pizzaiolo: Pizzaiolo) {
//        pizzaiolo.makePizza { pizza in
//            // Something when pizza is ready
//        }
//    }
//}
