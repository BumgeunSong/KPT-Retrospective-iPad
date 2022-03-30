//
//  SelectService.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/29.
//

import Foundation

struct SelectService {
    
    let layers = Layers.shared
    
    typealias onSelectHandler = ((Layer?, Layer?) -> Void)?
    let onSelect: onSelectHandler
    
    init(onSelect: onSelectHandler = nil) {
        self.onSelect = onSelect
    }
    
    func select(on point: Point, onSelect: onSelectHandler) {
        let unselected = layers.selected
        let newSelected = layers.layers.last(where: { layer in
            layer.contains(point)
        })
        
        layers.selected = newSelected
        
        onSelect?(unselected, newSelected)
    }
}
