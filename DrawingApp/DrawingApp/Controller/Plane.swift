//
//  Plane.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/01.
//

import Foundation
import OSLog

protocol PlaneDelegate {
    func didUpdateRectangles(_ plane: Plane)
}

class Plane {
    private let logger = Logger()
    private let factory = Factory()
    
    var selectedRectangleIndex: Int?
    
    var delegate: PlaneDelegate?
    
    private var rectangles: [Rectangle] = [] {
        didSet {
            guard let newRectangle = rectangles.last else { return }
            logger.info("New Rectangle Added in plane")
            logger.info("\(newRectangle, privacy: .public)")
        }
    }
    
    var rectangleCount: Int {
        return rectangles.count
    }
    
    subscript(index: Int) -> Rectangle {
        return rectangles[index]
    }
    
    init() {
        self.rectangles = factory.createRandomRectangles(number: 4)
    }
    
    func addRandomRectangle() {
        guard let rectangle = factory.createRandomRectangle() else {
            return
        }
        rectangles.append(rectangle)
        delegate?.didUpdateRectangles(self)
    }
    
    func tap(x: Double, y: Double) {
        let selectedRectangles = rectangles.filter { rectangle in
            (rectangle.x...rectangle.width+rectangle.x).contains(x)
            && (rectangle.y...rectangle.height+rectangle.y).contains(y)
        }
        guard let selectedRectangle = selectedRectangles.last else {
            return
        }
        guard let selectedRectangleIndex = self.rectangles.firstIndex(where: { rectangle in
            rectangle === selectedRectangle
        }) else { return }
        self.selectedRectangleIndex = selectedRectangleIndex
        
        logger.info("New Rectangle Selected in plane")
        logger.info("Index:\(selectedRectangleIndex+1),  \(selectedRectangle, privacy: .public)")
    }
    
}
