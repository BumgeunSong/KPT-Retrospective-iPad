//
//  Square.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import Foundation

class Square {
    init(id: String, width: Double, height: Double, positionX: Double, positionY: Double, color: Color) {
        self.id = id
        self.width = width
        self.height = height
        self.positionX = positionX
        self.positionY = positionY
        self.color = color
    }
    
    private var id: String
    
    private var width: Double
    private var height: Double
    
    private var positionX: Double
    private var positionY: Double
    
    private var color: Color
}

struct Color {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
}
