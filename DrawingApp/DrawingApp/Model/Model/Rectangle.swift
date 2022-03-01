//
//  Square.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import Foundation

class Rectangle: CustomStringConvertible {
    private var id: String
    
    var width: Double
    var height: Double
    
    var x: Double
    var y: Double
    
    var color: Color
    
    init(width: Double, height: Double, x: Double, y: Double, color: Color) {
        self.id = {
            var id = ""
            let partOfUUIDString = UUID().uuidString.suffix(9)
            for (i, char) in partOfUUIDString.enumerated() {
                if (i+1) % 3 == 0 && i != partOfUUIDString.count-1 { id += "\(char)-"}
                else { id += "\(char)" }
            }
            return id
        }()
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.color = color
    }
    
    
    var description: String {
        return "(\(id)), X:\(x), Y:\(y), W\(width), H\(height), R:\(color.red), G:\(color.green), B:\(color.blue), A: \(color.alpha)"
    }
    
}

