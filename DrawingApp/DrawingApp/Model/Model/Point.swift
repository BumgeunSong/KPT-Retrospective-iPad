//
//  Point.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/02.
//

import Foundation

struct Point: CustomStringConvertible {
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    static func random() -> Point {
        let randomX = Double(Int.random(in: 10...500))
        let randomY = Double(Int.random(in: 10...500))
        return Point(x: randomX, y: randomY)
    }
    
    var description: String {
        "X:\(x), Y:\(y)"
    }
}
