//
//  AddService.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/29.
//

import Foundation

// VM에서 들어온 입력을 Layers 모델에 추가
// Layers 모델을 VM에게 notify

struct AddService {
    
    let layers = Layers.shared
    
    typealias onAddHandler = ((Layer?, Layer?) -> Void)?
    let onAdd: onAddHandler
    
    init(onAdd: onAddHandler = nil) {
        self.onAdd = onAdd
    }
    
    func layerCount<T: Layer>(of type: T.Type) -> Int {
        return layers.layers.filter { $0 is T }.count
    }
    
    func add<T: Layer>(type: T.Type, imageData: Data? = nil, onAdd: ((Layer) -> Void)?) {
        guard let newLayer = LayerFactory.makeRandom(type, titleOrder: layerCount(of: type) + 1, from: imageData) else { return }
        
        layers.layers.append(newLayer)
        
        onAdd?(newLayer)
    }
}
