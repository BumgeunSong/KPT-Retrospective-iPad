//
//  Square.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import Foundation

class Rectangle: ViewModel {
    
    private(set) var id: String
    private(set) var origin: Point
    private(set) var size: Size
    private(set) var color: Color
    private(set) var alpha: Alpha
    
    init(id: String, origin: Point, size: Size, color: Color, alpha: Alpha) {
        self.id = id
        self.origin = origin
        self.size = size
        self.color = color
        self.alpha = alpha
    }
    
    static func create() -> Rectangle {
        let rectangleID = Rectangle.createID()
        let origin = Rectangle.createPoint()
        let size = Rectangle.createSize()
        let color = Rectangle.createColor()
        let alpha = Rectangle.createAlpha()
        
        return Rectangle(id: rectangleID, origin: origin, size: size, color: color, alpha: alpha)
    }
    
    var center: Point {
        Point(x: origin.x + (size.width / 2),
              y: origin.y + (size.height / 2))
    }

    func contains(_ point: Point) -> Bool {
        return (origin.x...origin.x+size.width).contains(point.x)
        && (origin.y...origin.y+size.height).contains(point.y)
    }
}

extension Rectangle: ColorMutable {
    func transform(to color: Color) {
        self.color = color
    }
}

extension Rectangle: AlphaMutable {
    func transform(to alpha: Alpha) {
        self.alpha = alpha
    }
}

extension Rectangle: OriginMutable {
    func transform(to origin: Point) {
        self.origin = origin
    }
}

extension Rectangle: CustomStringConvertible {
    var description: String {
        return "(\(id)), \(origin), \(size), \(color), \(alpha)"
    }
}
