//
//  Factory.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/02/28.
//

import Foundation

class Factory {
    func createRandomRectangle() -> Rectangle? {
        let (width, height) = createHeight()
        let (x, y) = createRandomOrigin()
        guard let color = createRandomColor() else { return nil }
        
        return Rectangle(width: width, height: height, x: x, y: y, color: color)
    }
    
    private func createHeight() -> (width: Double, height: Double) {
        return (Double(150), Double(120))
    }
    
    private func createRandomOrigin() -> (x: Double, y: Double) {
        let X = Double(Int.random(in: 10...500))
        let Y = Double(Int.random(in: 10...500))
        return (X, Y)
    }
    
    private func createRandomColor() -> Color? {
        return Color(r: Float.random(in: 0...255),
                     g: Float.random(in: 0...255),
                     b: Float.random(in: 0...255),
                     a: Float.random(in: 1...10))
    }
    
    func createRandomRectangles(number: Int) -> [Rectangle] {
        return (0..<number).compactMap { _ in createRandomRectangle() }
    }
}
