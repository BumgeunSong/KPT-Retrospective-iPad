//
//  PassivePlane.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/30.
//

import Foundation

protocol LayerContainable: AnyObject {
    var layers: [Layer] { get set }
    var selected: Layer? { get set }
}

class PassivePlane: LayerContainable {
    static let shared = PassivePlane() as LayerContainable
    
    var layers: [Layer]
    var selected: Layer?
    
    init(layers: [Layer] = [], selected: Layer? = nil) {
        self.layers = layers
        self.selected = selected
    }
}
