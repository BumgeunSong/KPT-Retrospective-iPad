//
//  ViewModel.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/07.
//

import Foundation

class ViewModel {
    private(set) var title: String
    private(set) var id: ID
    private(set) var origin: Point
    private(set) var size: Size
    
    init(title: String, id: ID, origin: Point, size: Size) {
        self.id = id
        self.origin = origin
        self.size = size
        self.title = title
    }
    
    var center: Point {
        Point(x: origin.x + (size.width / 2),
              y: origin.y + (size.height / 2))
    }
    
    var aspectRatio: Double {
        size.height / size.width
    }
    
    func contains(_ point: Point) -> Bool {
        return (origin.x...origin.x+size.width).contains(point.x)
        && (origin.y...origin.y+size.height).contains(point.y)
    }
    
    func set(to origin: Point) {
        self.origin = origin
    }
    
    func set(to size: Size) {
        self.size = size
    }
}

extension ViewModel: Hashable {
    static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

protocol ColorMutable {
    var color: Color { get }
    func set(to color: Color)
}

protocol AlphaMutable {
    var alpha: Alpha { get }
    func set(to alpha: Alpha)
}

protocol TextMutable {
    var text: String { get }
    func set(to text: String)
}
