//
//  CanvasView.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/07.
//

import UIKit

class CanvasView: UIImageView {
    let id: String
    
    override init(frame: CGRect) {
        // No id when initialized without ViewModel
        self.id = ""
        super.init(frame: frame)
    }
    
    init(viewModel: ViewModel) {
        self.id = viewModel.id
        
        let frame = Converter.toCGRect(origin: viewModel.origin, size: viewModel.size)
        super.init(frame: frame)
        
        if let photo = viewModel as? Photo {
            self.image = UIImage(data: photo.data)
        }
        
        if let colorMutableViewModel = viewModel as? ColorMutable {
            backgroundColor = Converter.toUIColor(colorMutableViewModel.color)
        }
        
        if let alphaMutableViewModel = viewModel as? AlphaMutable {
            alpha = Converter.toCGFloat(alphaMutableViewModel.alpha)
        }
    }
    
    func createTemporary() -> CanvasView {
        let temporaryView = CanvasView(frame: self.frame)
        
        if let image = self.image {
            temporaryView.image = image
        }
        
        if let backgroundColor = self.backgroundColor {
            temporaryView.backgroundColor = backgroundColor
        }
        
        temporaryView.alpha = self.alpha * 0.5
        
        temporaryView.layer.shadowColor = UIColor.black.cgColor
        temporaryView.layer.shadowOpacity = 1
        temporaryView.layer.shadowOffset = .zero
        temporaryView.layer.shouldRasterize = true
        return temporaryView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
