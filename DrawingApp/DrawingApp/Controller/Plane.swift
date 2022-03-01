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
    
    var delegate: PlaneDelegate?
    
    var rectangles: [Rectangle] = [] {
        didSet {
            guard let newRectangle = rectangles.last else { return }
            logger.info("New Rectangle Added in plane")
            
            logger.info("Rect:\(self.rectangles.count-1) \(newRectangle, privacy: .public)")
        }
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
    
}
