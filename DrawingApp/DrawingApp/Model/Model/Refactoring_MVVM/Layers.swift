//
//  Layers.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/29.
//

import Foundation

class Layers {
    
    // Use singleton for different services to access
    static let shared = Layers()
    
    var layers: [Layer]
    var selected: Layer?
    
    init(layers: [Layer] = [], selected: Layer? = nil) {
        self.layers = layers
        self.selected = selected
    }
}
