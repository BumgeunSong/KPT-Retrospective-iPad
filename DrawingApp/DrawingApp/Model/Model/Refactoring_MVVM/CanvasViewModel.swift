//
//  CanvasViewModel.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/29.
//

import Foundation
import UIKit




class CanvasViewModel {
    
    let addService = AddService()
    let newView = Observable<LayerConfiguration?>(nil)
    
    let selectService = SelectService()
    let unselectedView = Observable<UIView?>(nil)
    let newSelectedView = Observable<UIView?>(nil)
    
    var layerMap = [Layer: UIView]()
    
    private var temporaryView = Observable<UIView?>(nil)
    
    func add<T: Layer>(of layerType: T.Type, imageData: Data? = nil) {
        addService.add(type: layerType, imageData: imageData) { [weak self] newLayer in
            
            let config = ConfigurationFactory.makeConfiguration(from: newLayer)
            
            self?.newView.value = config
            
//            let newView = ViewFactory.create(from: newLayer)
//            if newView is UILabel { self?.resizeToFit() }
//            self?.layerMap[newLayer] = newView
//            self?.newView.value = newView
        }
    }
    
    
    
    func select(on point: Point) {
        selectService.select(on: point) { [weak self] unselected, newSelected in
            guard let unselected = unselected else { return }
            self?.unselectedView.value = self?.search(for: unselected)
            
            guard let selected = newSelected else { return }
            self?.newSelectedView.value = self?.search(for: selected)
        }
    }
    
    private func search(for layer: Layer) -> UIView? {
        return layerMap[layer]
    }
    
    private func resizeToFit() {
        
    }
    
    
}
