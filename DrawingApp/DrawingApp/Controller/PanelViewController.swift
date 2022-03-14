//
//  PanelViewController.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/02.
//

import UIKit

class PanelViewController: UIViewController {
    
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var AlphaLabel: UILabel!
    @IBOutlet weak var alphaSlider: UISlider!
    
    @IBOutlet weak var xOriginLabel: UILabel!
    @IBOutlet weak var yOriginLabel: UILabel!
    
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var isSizeFixedRatio: UISwitch!
    
    @IBOutlet weak var yOriginStepper: UIStepper!
    @IBOutlet weak var xOriginStepper: UIStepper!
    
    @IBOutlet weak var widthStepper: UIStepper!
    @IBOutlet weak var heightStpper: UIStepper!
    
    private var aspectRatio: Double?
    var completion: (() -> ())?
    @IBOutlet weak var textField: UITextField!
    
    enum Event {
        static let didChangeSlider = Notification.Name("sliderChanged")
        static let didTouchColorButton = Notification.Name("didTouchColorButton")
        static let didTouchOriginStepper = Notification.Name("didTouchOriginStepper")
        static let didTouchSizeStepper = Notification.Name("didTouchSizeStepper")
        static let didEditTextField = Notification.Name("didEditTextField")
    }
    
    enum InfoKey {
        static let value = "value"
        static let origin = "origin"
        static let size = "size"
        static let text = "text"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observePlane()
        observeCanvas()
        
        textField.addTarget(self, action: #selector(didEditTextField(_:)), for: .editingChanged)
    }
    
    private func observePlane() {
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectViewModel(_:)), name: Plane.Event.didSelectViewModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetColor(_:)), name: Plane.Event.didSetColor, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetAlpha(_:)), name: Plane.Event.didSetAlpha, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetSize(_:)), name: Plane.Event.didSetSize, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSetOrigin(_:)), name: Plane.Event.didSetOrigin, object: nil)
    }
    
    private func observeCanvas() {
        NotificationCenter.default.addObserver(self, selector: #selector(isDragging(_:)), name: CanvasViewController.Event.isDragging, object: nil)
    }
}

// MARK: - Use case: Display properties of selected view

extension PanelViewController {
    @objc func didSelectViewModel(_ notification: Notification) {
        guard let selected = notification.userInfo?[Plane.InfoKey.selected] as? ViewModel else {
            // Clear all panel when nothing selected
            clearPanel()
            return
        }
        
        // Every ViewModel should display size & origin
        displaySize(selected)
        displayOrigin(selected)
        
        // Display Property & Enable related controls when ViewModel is mutable
        if let colorMutable = selected as? ColorMutable {
            displayColor(colorMutable)
        } else {
            clearColorButton()
        }
        
        if let alphaMutable = selected as? AlphaMutable {
            displayAlpha(alphaMutable)
        } else {
            clearAlphaSlider()
        }
        
        if let textMutable = selected as? TextMutable {
            displayText(textMutable)
        } else {
            clearTextField()
        }
    }
    
    private func displayColor(_ selected: ColorMutable) {
        colorButton.isEnabled = true
        
        let selectedColor = UIColor(with: selected.color)
        colorButton.tintColor = selectedColor
        
        let selectedColorHex = selectedColor.toHex() ?? ""
        colorButton.setTitle(selectedColorHex, for: .normal)
        
        let visibleColor = selectedColor.isDark ? UIColor.white : UIColor.black
        colorButton.setTitleColor(visibleColor, for: .normal)
    }
    
    private func displayAlpha(_ selected: AlphaMutable) {
        alphaSlider.isEnabled = true
        
        let selectedAlpha = selected.alpha
        alphaSlider.value = selectedAlpha.value * 10
        
        let selectedAlphaString = String(format: "%.0f", selectedAlpha.value * 10)
        AlphaLabel.text = selectedAlphaString
    }
    
    private func displaySize(_ selected: ViewModel) {
        isSizeFixedRatio.isEnabled = true
        widthStepper.isEnabled = true
        heightStpper.isEnabled = true
        
        let selectedWidth = selected.size.width
        let selectedHeight = selected.size.height
        
        widthStepper.value = selectedWidth
        heightStpper.value = selectedHeight
        
        widthLabel.text = String(format: "%.0f", selectedWidth)
        heightLabel.text = String(format: "%.0f", selectedHeight)
        
        aspectRatio = selected.aspectRatio
    }
    
    private func displayOrigin(_ selected: ViewModel) {
        xOriginStepper.isEnabled = true
        yOriginStepper.isEnabled = true
        
        let selectedX = selected.origin.x
        let selectedY = selected.origin.y
        
        xOriginStepper.value = selectedX
        yOriginStepper.value = selectedY
        
        xOriginLabel.text = String(format: "%.0f", selectedX)
        yOriginLabel.text = String(format: "%.0f", selectedY)
        
    }
    
    private func displayText(_ selected: TextMutable) {
        textField.isEnabled = true
        textField.text = selected.text
    }
    
    private func displayTemporaryOrigin(_ origin: Point) {
        let selectedX = origin.x
        let selectedY = origin.y
        
        xOriginStepper.value = selectedX
        yOriginStepper.value = selectedY
        
        xOriginLabel.text = String(format: "%.0f", selectedX)
        yOriginLabel.text = String(format: "%.0f", selectedY)
    }
    
    private func clearPanel() {
        clearColorButton()
        clearAlphaSlider()
        clearSizeStepper()
        clearOriginStepper()
    }
    
    private func clearColorButton() {
        colorButton.setTitle("", for: .normal)
        colorButton.tintColor = UIColor.systemGray
        colorButton.isEnabled = false
    }
    
    private func clearAlphaSlider() {
        AlphaLabel.text = ""
        alphaSlider.value = 0
        alphaSlider.isEnabled = false
    }
    
    private func clearSizeStepper() {
        widthLabel.text = ""
        heightLabel.text = ""
        
        widthStepper.isEnabled = false
        heightStpper.isEnabled = false
        isSizeFixedRatio.isEnabled = false
    }
    
    private func clearOriginStepper() {
        xOriginLabel.text = ""
        yOriginLabel.text = ""
        
        xOriginStepper.isEnabled = false
        yOriginStepper.isEnabled = false
    }
    
    private func clearTextField() {
        textField.text = ""
        textField.isEnabled = false
    }
}

// MARK: - Use case: Set View & ViewModel using Controls

extension PanelViewController {
    
    func listenTouchColorButton(completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    @IBAction func didTouchColorButton(_ sender: UIButton) {
        completion?()
//        NotificationCenter.default.post(name: PanelViewController.Event.didTouchColorButton, object: self)
    }
    
    @objc func didSetColor(_ notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        guard let mutated = plane.selected as? ColorMutable else { return }
        displayColor(mutated)
    }
    
    @IBAction func didChangeSlider(_ sender: UISlider) {
        NotificationCenter.default.post(name: PanelViewController.Event.didChangeSlider, object: self, userInfo: [PanelViewController.InfoKey.value: sender.value])
    }
    
    @objc func didSetAlpha(_ notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        guard let mutated = plane.selected as? AlphaMutable else { return }
        displayAlpha(mutated)
    }
    
    @objc func isDragging(_ notification: Notification) {
        guard let temporaryOrigin = notification.userInfo?[CanvasViewController.InfoKey.origin] as? Point else { return }
        displayTemporaryOrigin(temporaryOrigin)
    }
    
    @IBAction func didTouchOriginStepper(_ sender: UIStepper) {
        let newOrigin = Point(x: xOriginStepper.value, y: yOriginStepper.value)
        NotificationCenter.default.post(name: PanelViewController.Event.didTouchOriginStepper, object: self, userInfo: [PanelViewController.InfoKey.origin: newOrigin])
    }
    
    @objc func didSetOrigin(_ notification: Notification) {
        guard let mutated = notification.userInfo?[Plane.InfoKey.set] as? ViewModel else { return }
        displayOrigin(mutated)
    }
    
    @IBAction func didTouchSizeStepper(_ sender: UIStepper) {
        var newSize = Size(width: 0, height: 0)
        
        if isSizeFixedRatio.isOn, let aspectRatio = aspectRatio {
            newSize = sender === widthStepper ?
            Size(width: widthStepper.value, height: widthStepper.value * aspectRatio) :
            Size(width: heightStpper.value * (1/aspectRatio) , height: heightStpper.value)
        } else {
            newSize = Size(width: widthStepper.value, height: heightStpper.value)
        }
        
        NotificationCenter.default.post(name: PanelViewController.Event.didTouchSizeStepper, object: self, userInfo: [PanelViewController.InfoKey.size: newSize])
    }
    
    @objc func didSetSize(_ notification: Notification) {
        guard let mutated = notification.userInfo?[Plane.InfoKey.set] as? ViewModel else { return }
        displaySize(mutated)
    }
    
    @objc func didEditTextField(_ sender: UITextField) {
        NotificationCenter.default.post(name: PanelViewController.Event.didEditTextField, object: self, userInfo: [PanelViewController.InfoKey.text: textField.text ?? ""])
    }
}
