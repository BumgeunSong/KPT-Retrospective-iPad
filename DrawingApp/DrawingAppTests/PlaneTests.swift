//
//  DrawingAppTests.swift
//  DrawingAppTests
//
//  Created by Bumgeun Song on 2022/02/28.
//

import XCTest
@testable import DrawingApp

class PlaneTests: XCTestCase {
    
    private var plane = Plane()
    
    override func setUp() {
        (0..<5).forEach { _ in plane.add(LayerType: .rectangle) }
        (0..<5).forEach { _ in plane.add(LayerType: .photo, data: Data()) }
        (0..<5).forEach { _ in plane.add(LayerType: .label) }
        super.setUp()
    }
    
    func testExample() throws {
        let two = 1 + 1
        XCTAssertEqual(two, 2)
    }
    
    func testAddRectangle() throws {
        let plane = Plane()
        plane.add(LayerType: .rectangle)
        XCTAssertEqual(plane.rectangleCount, 1)
    }
    
    func testAddPhoto() throws {
        let plane = Plane()
        plane.add(LayerType: .photo, data: Data())
        XCTAssertEqual(plane.photoCount, 1)
    }
    
    func testAddLabel() throws {
        let plane = Plane()
        plane.add(LayerType: .label)
        XCTAssertEqual(plane.labelCount, 1)
    }
    
    func testSelect() {
        for testIndex in 0..<plane.LayerCount {
            guard let testPoint = plane[testIndex]?.center else { return }
            plane.tap(on: testPoint)
            XCTAssertNotNil(plane.selected)
            XCTAssertTrue(plane.selected!.contains(testPoint))
        }
    }
    
    func testUnselect() {
        let emptyPoint = Point(x: Double(0), y: Double(0))
        plane.tap(on: emptyPoint)
        XCTAssertNil(plane.selected)
    }
    
    func testChangeSelectedColor() {
        guard let testPoint = plane[0]?.center else { return }
        plane.tap(on: testPoint)
        
        guard let selected = plane.selected as? ColorMutable else { return }
        
        let color = Color.random()
        plane.changeSelected(toColor: color)
        
        XCTAssertEqual(selected.color.red, color.red)
        XCTAssertEqual(selected.color.green, color.green)
        XCTAssertEqual(selected.color.blue, color.blue)
    }
    
    func testChangeSelectedAlpha() {
        guard let testPoint = plane[0]?.center else { return }
        plane.tap(on: testPoint)
        
        let alpha = Alpha.random()
        plane.changeSelected(toAlpha: alpha)
        
        guard let selected = plane.selected as? AlphaMutable else { return }
        XCTAssertEqual(selected.alpha.value, alpha.value)
    }
    
    func testChangeSelectedOrigin() {
        guard let testPoint = plane[0]?.center else { return }
        plane.tap(on: testPoint)
        
        let origin = Point.random()
        plane.changeSelected(toOrigin: origin)
        
        XCTAssertEqual(plane.selected?.origin.x, origin.x)
        XCTAssertEqual(plane.selected?.origin.y, origin.y)
        
    }
    
    func testChangeSelectedSize() {
        guard let testPoint = plane[0]?.center else { return }
        plane.tap(on: testPoint)
        
        let size = Size.standard()
        plane.changeSelected(toSize: size)
        
        XCTAssertEqual(plane.selected?.size.width, size.width)
        XCTAssertEqual(plane.selected?.size.height, size.height)
    }
    
    func testChangeLayerOrigin() {
        for i in 0..<plane.LayerCount {
            let point = Point.random()
            guard let Layer = plane[i] else { return }
            plane.change(Layer: Layer, toOrigin: point)
            XCTAssertEqual(Layer.origin.x, point.x)
            XCTAssertEqual(Layer.origin.y, point.y)
        }
    }
    
    func testChangeLayerSize() {
        for i in 0..<plane.LayerCount {
            let size = Size(width: Double.random(in: 1...300), height: Double.random(in: 1...300))
            guard let Layer = plane[i] else { return }
            plane.change(Layer: Layer, toSize: size)
            XCTAssertEqual(Layer.size.width, size.width)
            XCTAssertEqual(Layer.size.height, size.height)
        }
    }
}
