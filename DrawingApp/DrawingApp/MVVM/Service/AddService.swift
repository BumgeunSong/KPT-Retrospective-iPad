//
//  AddService.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/30.
//

import Foundation

struct AddService {
    
    let layers = Layers.shared
    
    typealias onAddHandler = ((Layer) -> Void)?
    
    func add<T: Layer>(type: T.Type, imageData: Data? = nil, onAdd: onAddHandler) {
        guard let newLayer = LayerFactory.makeRandom(type, titleOrder: layerCount(of: type) + 1, from: imageData) else { return }
        
        layers.layers.append(newLayer)
        
        onAdd?(newLayer)
    }
    
    private func layerCount<T: Layer>(of type: T.Type) -> Int {
        return layers.layers.filter { $0 is T }.count
    }
}
