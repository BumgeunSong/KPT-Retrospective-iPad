//
//  DrawingAppTests.swift
//  DrawingAppTests
//
//  Created by Bumgeun Song on 2022/02/28.
//

import XCTest
@testable import DrawingApp

class PlaneTests: XCTestCase {
    
    func testExample() throws {
        let two = 1 + 1
        XCTAssertEqual(two, 2)
    }
    
    func testAddRectangle() throws {
        let plane = Plane()
        plane.addRectangle()
        XCTAssertEqual(plane.rectangleCount, 1)
    }
    
    func testAddPhoto() throws {
        let plane = Plane()
        plane.addPhoto(data: Data())
        XCTAssertEqual(plane.photoCount, 1)
    }
    
    func testSelectedWhenTapped() {
        let plane = Plane()
        (0..<5).forEach { _ in plane.addRectangle() }
        (0..<5).forEach { _ in plane.addPhoto(data: Data()) }
        
        for testIndex in 0..<plane.viewModelCount {
            let testPoint = plane[testIndex].center
            plane.tap(on: testPoint)
            XCTAssertNotNil(plane.selected)
            XCTAssertTrue(plane.selected!.contains(testPoint))
        }
    }
    
    func testSelectedWhenEmptyTapped() {
        let plane = Plane()
        (0..<5).forEach { _ in plane.addRectangle() }
        (0..<5).forEach { _ in plane.addPhoto(data: Data()) }
        
        let emptyPoint = Point(x: Double(0), y: Double(0))
        plane.tap(on: emptyPoint)
        XCTAssertNil(plane.selected)
    }
    
    func testTransformColor() {
        let plane = Plane()
        (0..<5).forEach { _ in plane.addRectangle() }
        
        let testPoint = plane[0].center
        plane.tap(on: testPoint)
        
        guard let selected = plane.selected as? ColorMutable else { return }
        
        let color = Rectangle.createColor()
        plane.transform(to: color)
        
        XCTAssertEqual(selected.color.red, color.red)
        XCTAssertEqual(selected.color.green, color.green)
        XCTAssertEqual(selected.color.blue, color.blue)
    }
    
    func testTransformAlpha() {
        let plane = Plane()
        (0..<5).forEach { _ in plane.addRectangle() }
        (0..<5).forEach { _ in plane.addPhoto(data: Data()) }
        
        let testPoint = plane[0].center
        plane.tap(on: testPoint)
        
        let alpha = Alpha(1)!
        plane.transform(to: alpha)
        
        guard let selected = plane.selected as? AlphaMutable else { return }
        XCTAssertEqual(selected.alpha.value, alpha.value)
    }
    
    func testTransformOrigin() {
        let plane = Plane()
        (0..<5).forEach { _ in plane.addRectangle() }
        (0..<5).forEach { _ in plane.addPhoto(data: Data()) }
        
        for i in 0..<plane.viewModelCount {
            let point = Rectangle.createPoint()
            plane.transform(plane[i].id, to: point)
            XCTAssertEqual(plane[i].origin.x, point.x)
            XCTAssertEqual(plane[i].origin.y, point.y)
        }
    }
}
