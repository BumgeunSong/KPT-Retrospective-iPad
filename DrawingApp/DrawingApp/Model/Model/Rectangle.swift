//
//  Square.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import Foundation

class Rectangle: ViewModel {
    
    private(set) var color: Color
    private(set) var alpha: Alpha
    
    init(id: ID, origin: Point, size: Size, color: Color, alpha: Alpha) {
        self.color = color
        self.alpha = alpha
        super.init(id: id, origin: origin, size: size)
    }
    
    static func random() -> Rectangle {
        let rectangleID = ID.random()
        let origin = Point.random()
        let size = Size.standard()
        let color = Color.random()
        let alpha = Alpha.random()
        
        return Rectangle(id: rectangleID, origin: origin, size: size, color: color, alpha: alpha)
    }
}

extension Rectangle: ColorMutable {
    func set(to color: Color) {
        self.color = color
    }
}

extension Rectangle: AlphaMutable {
    func set(to alpha: Alpha) {
        self.alpha = alpha
    }
}

extension Rectangle: CustomStringConvertible {
    var description: String {
        return "(\(id)), \(origin), \(size), \(color), \(alpha)"
    }
}
