//
//  Photo.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/07.
//

import Foundation

class Photo: ViewModel {
    
    private(set) var id: String
    private(set) var origin: Point
    private(set) var size: Size
    private(set) var data: Data
    private(set) var alpha: Alpha

    init(id: String, origin: Point, size: Size, photo: Data, alpha: Alpha) {
        self.id = id
        self.origin = origin
        self.size = size
        self.data = photo
        self.alpha = alpha
    }
    
    static func create(from data: Data) -> Photo {
        let photoID = Photo.createID()
        let origin = Photo.createPoint()
        let size = Photo.createSize()
        let alpha = Photo.createAlpha()
        
        return Photo(id: photoID, origin: origin, size: size, photo: data, alpha: alpha)
    }
    
    var center: Point {
        Point(x: origin.x + (size.width / 2),
              y: origin.y + (size.height / 2))
    }

    func contains(_ point: Point) -> Bool {
        return (origin.x...origin.x+size.width).contains(point.x)
        && (origin.y...origin.y+size.height).contains(point.y)
    }
}


extension Photo: AlphaMutable {
    func transform(to alpha: Alpha) {
        self.alpha = alpha
    }
}

extension Photo: OriginMutable {
    func transform(to origin: Point) {
        self.origin = origin
    }
}
    

extension Photo: CustomStringConvertible {
    var description: String {
        return "(\(id)), \(origin), \(size), \(data), \(alpha)"
    }
}
