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
        
        for index in 0..<plane.rectangleCount {
            if index < existingViewCount { continue }
            DispatchQueue.main.async {
                let rectangleView = RectangleView(from: plane[index])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
                rectangleView.addGestureRecognizer(tap)
                self.view.addSubview(rectangleView)
            }
        }
    }
    
    @IBAction func addRectanglePressed(_ sender: UIButton) {
        plane.addRandomRectangle()
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: view)
        plane.selected(x: Double(location.x), y: Double(location.y))
        
        guard let gestureView = gesture.view as? RectangleView else { return }
        gestureView.layer.borderWidth = 3
        gestureView.layer.borderColor = UIColor.link.cgColor
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
