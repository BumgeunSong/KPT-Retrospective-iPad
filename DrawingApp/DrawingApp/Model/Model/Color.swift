//
//  Color.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import Foundation

struct Color {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float
    
    init?(r red: Float, g green: Float, b blue: Float, a alpha: Float) {
        guard red >= 0, red <= 255, green >= 0, green <= 255, blue >= 0, blue <= 255, alpha >= 0, alpha <= 10 else { return nil }
        self.red = red / 255
        self.green = green / 255
        self.blue = blue / 255
        self.alpha = alpha / 10
    }
}
