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
    private var viewIDMap = [String: UIView]()
    
    private let photoPickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observePlane()
        observePanel()
        
        setUpInitialModels()
        setUpRecognizer()
        
        photoPickerController.delegate = self
    }
}

// MARK: - Use case: Launch App

extension CanvasViewController {
    
    private func observePlane() {
        NotificationCenter.default.addObserver(self, selector: #selector(didAddViewModel(_:)), name: Plane.addViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectViewModel(_:)), name: Plane.selectViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didMutateColor(_:)), name: Plane.mutateColorViewModel, object: plane)
        NotificationCenter.default.addObserver(self, selector: #selector(didMutateAlpha(_:)), name: Plane.mutateAlphaViewModel, object: plane)
    }
    
    private func observePanel() {
        NotificationCenter.default.addObserver(self, selector: #selector(sliderChanged(_:)), name: PanelViewController.sliderChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorButtonPressed(_:)), name: PanelViewController.colorButtonPressed, object: nil)
    }
    
    private func setUpRecognizer() {
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
        guard let newBaseView = createBaseView(from: newViewModel) else { return }
        addViewID(newBaseView)
        view.addSubview(newBaseView)
    }
    
    private func createBaseView(from viewModel: ViewModel) -> BaseView? {
        return BaseView(viewModel: viewModel)
    }
    
    private func addViewID(_ new: BaseView) {
        viewIDMap[new.id] = new
    }
}

// MARK: - Use Case: Add New Photo

extension CanvasViewController {
    
    @IBAction func addPhotoPressed(_ sender: UIButton) {
        present(photoPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //
        guard let image = info[.originalImage] as? UIImage else { return }
        self.didPhotoSelected(image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func didPhotoSelected(_ image: UIImage) {
        print("Photo will be created")
    }
    
}

// MARK: - Use Case: Select Rectangle

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
    
    private func searchView(for viewModel: ViewModel) -> UIView? {
        return viewIDMap[viewModel.id]
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

// MARK: - Use Case: Transform Rectangle

extension CanvasViewController {
    
    @objc func colorButtonPressed(_ notification: Notification) {
        plane.transform()
    }
    
    @objc func didMutateColor(_ notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        guard let mutated = plane.selected as? ColorMutable else { return }
        let mutatedUIView = searchView(for: mutated as! ViewModel)
        mutatedUIView?.backgroundColor = Converter.toUIColor(mutated.color)
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
        let mutatedUIView = searchView(for: mutated as! ViewModel)
        mutatedUIView?.alpha = Converter.toCGFloat(mutated.alpha)
    }
}
