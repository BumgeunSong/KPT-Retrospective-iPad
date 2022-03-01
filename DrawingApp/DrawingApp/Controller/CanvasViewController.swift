//
//  CanvasViewController.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/01.
//

import UIKit
import OSLog

class CanvasViewController: UIViewController, PlaneDelegate {
    private let plane = Plane()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plane.delegate = self
        didUpdateRectangles(plane)
    }
    
    func didUpdateRectangles(_ plane: Plane) {
        let existingViewCount = view.subviews.filter({ subview in
            subview is RectangleView
        }).count
        
        for (index, rect) in plane.rectangles.enumerated() {
            if index < existingViewCount { continue }
            DispatchQueue.main.async {
                self.view.addSubview(RectangleView(from: rect))
            }
        }
    }
    
    @IBAction func addRectanglePressed(_ sender: UIButton) {
        plane.addRandomRectangle()
    }
}

class RectangleView: UIView {
    init(from rectangle: Rectangle) {
        let frame = CGRect(x: rectangle.x, y: rectangle.y, width: rectangle.width, height: rectangle.height)
        super.init(frame: frame)
        
        let color = rectangle.color
        setupColor(from: color)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupColor(from color: Color) {
        let red = CGFloat(color.red)
        let green = CGFloat(color.green)
        let blue = CGFloat(color.blue)
        let alpha = CGFloat(color.alpha)
        backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
