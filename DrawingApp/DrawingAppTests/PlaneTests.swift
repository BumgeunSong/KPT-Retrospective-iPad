//
//  PlaneTests.swift
//  DrawingAppTests
//
//  Created by Bumgeun Song on 2022/03/02.
//

import XCTest
@testable import DrawingApp

class PlaneTests: XCTestCase {

    func testExample() throws {
        let two = 1 + 1
        XCTAssertEqual(two, 2)
    }
    
    func testRectangleCount() throws {
        // given
        // when
        // then
    }
    
    func testRectangleCountWhenInitialized() throws {
        // when 처음 생성했을 때
        let plane = Plane()
        
        // then 사각형 4개 들어가있어야 함.
        XCTAssertEqual(plane.rectangleCount, 4)
    }
    
    func testAddRandomRectangle() {
        // when Plane에 사각형 추가했을 때
        let plane = Plane()
        let prevCount = plane.rectangleCount
        
        plane.addRandomRectangle()
        let currentCount = plane.rectangleCount

        // then count가 이전 대비 +1 늘어나야 함.
        XCTAssertEqual(prevCount+1, currentCount)
    }
    
    func testSelectRectangleTapped() {
        let plane = Plane()
        
        // when center x, y 좌표가 왔을 때
        // then x, y 좌표에 해당하는 사각형이 select되어야 함.
        
        for testIndex in 0..<plane.rectangleCount {
            let rectangle1 = plane[testIndex]
            let (centerX, centerY) = (rectangle1.x + rectangle1.width/2, rectangle1.y + rectangle1.height/2)
            plane.tap(x: centerX, y: centerY)
            
            XCTAssertNotNil(plane.selectedRectangleIndex)
            
            let selected = plane[plane.selectedRectangleIndex!]
            XCTAssertTrue((selected.x...selected.x+selected.width).contains(centerX))
            XCTAssertTrue((selected.y...selected.y+selected.height).contains(centerY))
        }
    }
    
    func testSelectEmptyTapped() {
        // when 빈 공간에 대한 x, y 좌표가 왔을 때
        // then 아무것도 return 하지 않아야 함.
        let (emptyX, emptyY) =
    }
}
