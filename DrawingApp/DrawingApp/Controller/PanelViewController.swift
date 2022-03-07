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
    
    static let sliderChanged = Notification.Name("sliderChanged")
    static let colorButtonPressed = Notification.Name("colorButtonPressed")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observePlane()
    }
    
    private func observePlane() {
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectViewModel(_:)), name: Plane.selectViewModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didMutateColor(_:)), name: Plane.mutateColorViewModel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didMutateAlpha(_:)), name: Plane.mutateAlphaViewModel, object: nil)
    }
}

// MARK: - Use case: Display properties of selected view

extension PanelViewController {
    @objc func didSelectViewModel(_ notification: Notification) {

        guard let selected = notification.userInfo?["new"] as? ViewModel else {
            clearColorButton()
            clearAlphaSlider()
            return
        }
        
        if let colorMutableViewModel = selected as? ColorMutable {
            displayColor(colorMutableViewModel)
        } else {
            clearColorButton()
        }
        
        if let alphaMutableViewModel = selected as? AlphaMutable {
            displayAlpha(alphaMutableViewModel)
        } else {
            clearAlphaSlider()
        }
    }
    
    private func displayColor(_ selected: ColorMutable) {
        colorButton.isEnabled = true
        
        let selectedColor = Converter.toUIColor(selected.color)
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
        
        let selectedAlphaString = String.init(format: "%.0f", selectedAlpha.value * 10)
        AlphaLabel.text = selectedAlphaString
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
}

// MARK: - Use case: Mutate View using Controls

extension PanelViewController {
    
    
    @IBAction func ColorButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: PanelViewController.colorButtonPressed, object: self)
    }
    
    @objc func didMutateColor(_ notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        guard let mutated = plane.selected as? ColorMutable else { return }
        displayColor(mutated)
    }
    
    @IBAction func SliderChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: PanelViewController.sliderChanged, object: self, userInfo: ["value": sender.value])
    }
    
    @objc func didMutateAlpha(_ notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        guard let mutated = plane.selected as? AlphaMutable else { return }
        displayAlpha(mutated)
    }
}
