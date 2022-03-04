//
//  Factory.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import Foundation

class Factory {
    static func createRectangle() -> Rectangle {
        let rectangleID = createID()
        let origin = createPoint()
        let size = createSize()
        let color = createColor()
        let alpha = createAlpha()
        
        return Rectangle(id: rectangleID, origin: origin, size: size, color: color, alpha: alpha)
    }
    
    private static func createID() -> String {
        let uuidStrings = UUID().uuidString.components(separatedBy: "-")
        let partialID1 = uuidStrings[0].prefix(3)
        let partialID2 = uuidStrings[1].prefix(3)
        let partialID3 = uuidStrings[2].prefix(3)
        return "\(partialID1)-\(partialID2)-\(partialID3)"
    }
    
    private static func createPoint() -> Point {
        let randomX = Double(Int.random(in: 10...500))
        let randomY = Double(Int.random(in: 10...500))
        return Point(x: randomX, y: randomY)
    }
    
    private static func createSize() -> Size {
        return Size(width: 150.0, height: 120.0)
    }
    
    static func createColor() -> Color {
        return Color(r: Float.random(in: 0...255),
                     g: Float.random(in: 0...255),
                     b: Float.random(in: 0...255))!
    }
    
    private static func createAlpha() -> Alpha {
        return Alpha(Int.random(in: 1...10))!
    }
}
