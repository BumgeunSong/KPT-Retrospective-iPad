//
//  ViewModel.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/07.
//

import Foundation

protocol ViewModel {
    var id: String { get }
    var center: Point { get }
    var origin: Point { get }
    var size: Size { get }
    
    func contains(_ point: Point) -> Bool
    
    static func createID() -> String
    static func createPoint() -> Point
    static func createSize() -> Size
}

// Implement Factory method in ViewModel Protocol
extension ViewModel {
    static func createID() -> String {
        let uuidStrings = UUID().uuidString.components(separatedBy: "-")
        let partialID1 = uuidStrings[0].prefix(3)
        let partialID2 = uuidStrings[1].prefix(3)
        let partialID3 = uuidStrings[2].prefix(3)
        return "\(partialID1)-\(partialID2)-\(partialID3)"
    }
    
    static func createPoint() -> Point {
        let randomX = Double(Int.random(in: 10...700))
        let randomY = Double(Int.random(in: 10...700))
        return Point(x: randomX, y: randomY)
    }
    
    static func createSize() -> Size {
        return Size(width: 150.0, height: 120.0)
    }
    
    static func createColor() -> Color {
        return Color(r: Float.random(in: 0...255),
                     g: Float.random(in: 0...255),
                     b: Float.random(in: 0...255))!
    }
    
    static func createAlpha() -> Alpha {
        return Alpha(Int.random(in: 3...10))!
    }
}

protocol OriginMutable {
    var origin: Point { get }
    func transform(to origin: Point)
}

protocol ColorMutable {
    var color: Color { get }
    func transform(to color: Color)
}

protocol AlphaMutable {
    var alpha: Alpha { get }
    func transform(to alpha: Alpha)
}
