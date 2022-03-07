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
    private var viewIDMap = [String: CanvasView]()
    private let photoPicker = UIImagePickerController()
    private var temporaryView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observePlane()
        observePanel()
        
        setUpInitialModels()
        setUpTapRecognizer()
        
        photoPicker.delegate = self
    }
}

// MARK: - Use case: Launch App

extension CanvasViewController {
    
    private func observePlane() {
        NotificationCenter.default.addObserver(self, selector: #selector(didAddViewModel(_:)), name: Plane.addViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectViewModel(_:)), name: Plane.selectViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didMutateColor(_:)), name: Plane.mutateColorViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didMutateAlpha(_:)), name: Plane.mutateAlphaViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didMutateOrigin(_:)), name: Plane.mutateOriginViewModel, object: plane)
    }
    
    private func observePanel() {
        NotificationCenter.default.addObserver(self, selector: #selector(sliderChanged(_:)), name: PanelViewController.sliderChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorButtonPressed(_:)), name: PanelViewController.colorButtonPressed, object: nil)
    }
    
    private func setUpTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap)
    }
    
    private func setUpInitialModels() {
        (0..<4).forEach { _ in plane.addRectangle() }
    }
}

// MARK: - Use Case: Add New Rectangle

extension CanvasViewController {
    
    @IBAction func addRectanglePressed(_ sender: UIButton) {
        plane.addRectangle()
    }
    
    @objc func didAddViewModel(_ notification: Notification) {
        guard let newViewModel = notification.userInfo?["new"] as? ViewModel else { return }
        guard let newCanvasView = createView(from: newViewModel) else { return }
        addViewID(newCanvasView)
        
        view.addSubview(newCanvasView)
        setupPanRecognizer(newCanvasView)
    }
    
    private func createView(from viewModel: ViewModel) -> CanvasView? {
        return CanvasView(viewModel: viewModel)
    }
    
    private func addViewID(_ new: CanvasView) {
        viewIDMap[new.id] = new
    }
}

// MARK: - Use Case: Add New Photo

extension CanvasViewController {
    
    @IBAction func addPhotoPressed(_ sender: UIButton) {
        present(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        guard let imageData = image.pngData() else { return }
        
        plane.addPhoto(data: imageData)
        picker.dismiss(animated: true, completion: nil)
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
        if let new = notification.userInfo?["new"] as? ViewModel {
            guard let newView = searchView(for: new) else { return }
            changeBorder(newView)
        }
        
        if let old = notification.userInfo?["old"] as? ViewModel {
            guard let oldView = searchView(for: old) else { return }
            clearBorder(oldView)
        }
    }
    
    private func searchView(for viewModel: ViewModel) -> CanvasView? {
        return viewIDMap[viewModel.id]
    }
    
    private func changeBorder(_ view: CanvasView) {
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func clearBorder(_ view: CanvasView) {
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
    }
    
}

// MARK: - Use Case: Transform Rectangle

extension CanvasViewController {
    
    @objc func colorButtonPressed(_ notification: Notification) {
        plane.transform()
    }
    
    @objc func didMutateColor(_ notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        guard let mutated = plane.selected as? ColorMutable else { return }
        let mutatedCanvasView = searchView(for: mutated as! ViewModel)
        mutatedCanvasView?.backgroundColor = Converter.toUIColor(mutated.color)
    }
    
    @objc func sliderChanged(_ notification: Notification) {
        guard let value = notification.userInfo?["value"] as? Float else { return }
        
        if let alpha = Alpha(value) {
            plane.transform(to: alpha)
        }
    }
    
    @objc func didMutateAlpha(_ notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        guard let mutated = plane.selected as? AlphaMutable else { return }
        let mutatedCavnasView = searchView(for: mutated as! ViewModel)
        mutatedCavnasView?.alpha = Converter.toCGFloat(mutated.alpha)
    }
}

// MARK: - Use Case: Drag CanvasView

extension CanvasViewController {
    
    private func setupPanRecognizer(_ canvasView: CanvasView) {
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
        guard let gestureView = gesture.view as? CanvasView else { return }
        guard gesture.state == .began else { return }
        let temporaryView = gestureView.createTemporary()
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
    }
    
    private func endPan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view as? CanvasView else { return }
        guard let temporaryView = temporaryView else { return }
        guard gesture.state == .ended else { return }
        let lastOrigin = Point(x: temporaryView.frame.origin.x,
                               y: temporaryView.frame.origin.y)
        plane.transform(gestureView.id, to: lastOrigin)
        temporaryView.removeFromSuperview()
    }
    
    @objc func didMutateOrigin(_ notification: Notification) {
        guard let mutated = notification.userInfo?["mutated"] as? OriginMutable else { return }
        
        let mutatedCavnasView = searchView(for: mutated as! ViewModel)
        mutatedCavnasView?.frame.origin = Converter.toCGPoint(mutated.origin)
    }
}
