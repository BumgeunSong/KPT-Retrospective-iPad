//
//  BaseView.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/03.
//

import UIKit

enum ViewFactory {
    static func create(from viewModel: ViewModel) -> UIView? {
        switch viewModel {
        case let rectangle as Rectangle:
            return createView(from: rectangle)
        case let photo as Photo:
            return createView(from: photo)
        case let label as Label:
            return createView(from: label)
        default:
            return nil
        }
    }
    
    private static func createView(from rectangle: Rectangle) -> UIView {
        let frame = CGRect(origin: rectangle.origin, size: rectangle.size)
        let view = UIView(frame: frame)
        
        view.backgroundColor = UIColor(with: rectangle.color)
        view.alpha = CGFloat(with: rectangle.alpha)
        
        return view
    }
    
    private static func createView(from photo: Photo) -> UIImageView {
        let frame = CGRect(origin: photo.origin, size: photo.size)
        let view = UIImageView(frame: frame)
        
        view.image = UIImage(data: photo.data)
        view.alpha = CGFloat(with: photo.alpha)
        
        return view
    }
    
    private static func createView(from label: Label) -> UILabel {
        let frame = CGRect(origin: label.origin, size: label.size)
        let view = UILabel(frame: frame)
        
        view.text = label.text
        view.font = UIFont.systemFont(ofSize: CGFloat(label.fontSize))
        view.textColor = UIColor(with: label.fontColor)
        
        return view
    }
    
    static func clone(_ original: UIView) -> UIView {
        switch original {
        case let imageView as UIImageView:
            return clone(imageView)
        case let label as UILabel:
            return clone(label)
        default:
            let clone = UIView(frame: original.frame)
            
            if let backgroundColor = original.backgroundColor {
                clone.backgroundColor = backgroundColor
            }
            
            applyCloneEffect(clone)
            return clone
        }
    }
    
    private static func clone(_ original: UIImageView) -> UIImageView {
        let clone = UIImageView(frame: original.frame)
        
        if let image = original.image {
            clone.image = image
        }

        applyCloneEffect(clone)
        
        return clone
    }
    
    private static func clone(_ original: UILabel) -> UILabel {
        let clone = UILabel(frame: original.frame)
        
        clone.text = original.text
        clone.font = UIFont.systemFont(ofSize: original.font.pointSize)
        clone.textColor = original.textColor
        applyCloneEffect(clone)
        
        return clone
    }
    
    private static func applyCloneEffect(_ clone: UIView) {
        clone.alpha *= 0.5
        
        clone.layer.shadowColor = UIColor.black.cgColor
        clone.layer.shadowOpacity = 1
        clone.layer.shadowOffset = .zero
        clone.layer.shouldRasterize = true
    }
}
