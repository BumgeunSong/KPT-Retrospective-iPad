//
//  LayerViewConfiguration.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/29.
//

import Foundation
import UIKit


enum ConfigurationFactory {
    static func makeConfiguration(from layer: Layer) -> LayerConfiguration? {
        switch layer {
        case let rectangle as Rectangle:
            return RectangleConfiguration(
                size: rectangle.size,
                origin: rectangle.origin,
                alpha: rectangle.alpha,
                backgroundColor: rectangle.color)
        case let photo as Photo:
            return PhotoConfiguration(
                size: photo.size,
                origin: photo.origin,
                alpha: photo.alpha,
                imageData: photo.data)
        case let label as Label:
            return LabelConfiguration(
                size: label.size,
                origin: label.origin,
                text: label.getText,
                fontSize: label.fontSize)
        case let postIt as PostIt:
            return PostitConfiguration(
                size: postIt.size,
                origin: postIt.origin,
                text: postIt.getText,
                backgroundColor: postIt.color)
        default:
            return nil
        }
    }
}

class LayerConfiguration {
    internal init(size: Size, origin: Point) {
        self.size = size
        self.origin = origin
    }
    
    private var size: Size
    private var origin: Point
    
    var frame: CGRect {
        return CGRect(origin: origin, size: size)
    }
}

class RectangleConfiguration: LayerConfiguration {
    internal init(size: Size, origin: Point, alpha: Alpha, backgroundColor: Color) {
        self.alpha = alpha
        self.color = backgroundColor
        super.init(size: size, origin: origin)
    }
    
    private var alpha: Alpha
    private var color: Color
    
    var cgAlpha: CGFloat {
        CGFloat(with: alpha)
    }
    
    var backgroundColor: UIColor {
        UIColor(with: color)
    }
}

class PhotoConfiguration: LayerConfiguration {
    internal init(size: Size, origin: Point, alpha: Alpha, imageData: Data?) {
        self.alpha = alpha
        self.imageData = imageData
        super.init(size: size, origin: origin)
    }
    
    private var alpha: Alpha
    private var imageData: Data?
    
    var cgAlpha: CGFloat {
        CGFloat(with: alpha)
    }
    
    var uiImage: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}

class LabelConfiguration: LayerConfiguration {
    init(size: Size, origin: Point, text: String, fontSize: Float) {
        self.text = text
        self.fontSize = fontSize
        super.init(size: size, origin: origin)
    }
    
    private(set) var text: String
    private var fontSize: Float
    
    var uiFont: UIFont {
        UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
}

class PostitConfiguration: LayerConfiguration {
    internal init(size: Size, origin: Point, text: String, backgroundColor: Color) {
        self.text = text
        self.bgColor = backgroundColor
        super.init(size: size, origin: origin)
    }
    
    var textColor: UIColor {
        return backgroundColor.isDark ? .white : .black
    }
    
    var backgroundColor: UIColor {
        UIColor(with: bgColor)
    }
    
    private var text: String
    private var bgColor: Color
    
    let defaultTextContainerInset = UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16)
    
    let isEditable = false
    
    private var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
}
