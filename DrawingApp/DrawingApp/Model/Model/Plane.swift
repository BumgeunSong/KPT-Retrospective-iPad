//
//  Plane.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/02.
//

import Foundation

class Plane {
    enum Event {
        static let didAddViewModel = Notification.Name("didAddViewModel")
        static let didSelectViewModel = Notification.Name("didSelectViewModel")
        static let didSetColor = Notification.Name("didSetColor")
        static let didSetAlpha = Notification.Name("didSetAlpha")
        static let didSetOrigin = Notification.Name("didSetOrigin")
        static let didSetSize = Notification.Name("didSetSize")
        static let didSetText = Notification.Name("didSetText")
    }
    
    enum InfoKey {
        static let added = "added"
        static let selected = "selected"
        static let unselected = "unselected"
        static let set = "set"
    }
    
    private(set) var viewModels: [ViewModel] = [] {
        didSet {
            guard let newModel = viewModels.last else { return }
            Log.info("Added: \(newModel)")
        }
    }
    
    var selected: ViewModel?
    
    var rectangleCount: Int {
        viewModels.filter { $0 is Rectangle }.count
    }
    
    var photoCount: Int {
        viewModels.filter { $0 is Photo }.count
    }
    
    var labelCount: Int {
        viewModels.filter { $0 is Label }.count
    }
    
    var viewModelCount: Int {
        viewModels.count
    }
    
    subscript(index: Int) -> ViewModel? {
        return (0..<viewModels.count).contains(index) ? viewModels[index] : nil
    }
    
    func addRectangle() {
        let newRectangle = Rectangle.random(of: rectangleCount+1)
        viewModels.append(newRectangle)
        NotificationCenter.default.post(name: Plane.Event.didAddViewModel, object: self, userInfo: [Plane.InfoKey.added: newRectangle])
    }
    
    func addPhoto(data: Data) {
        let newPhoto = Photo.random(of: photoCount+1, from: data)
        viewModels.append(newPhoto)
        NotificationCenter.default.post(name: Plane.Event.didAddViewModel, object: self, userInfo: [Plane.InfoKey.added: newPhoto])
    }
    
    func addLabel() {
        let newLabel = Label.random(of: labelCount+1)
        viewModels.append(newLabel)
        NotificationCenter.default.post(name: Plane.Event.didAddViewModel, object: self, userInfo: [Plane.InfoKey.added: newLabel])
    }
    
    func select(at index: Int) {
        let unselected = selected
        self.selected = viewModels[index]
        NotificationCenter.default.post(name: Plane.Event.didSelectViewModel, object: self, userInfo: [Plane.InfoKey.unselected: unselected as Any, Plane.InfoKey.selected: selected as Any])
    }
    
    func tap(on point: Point) {
        let unselected = selected
        self.selected = viewModels.last(where: { viewModel in
            viewModel.contains(point)
        })
        NotificationCenter.default.post(name: Plane.Event.didSelectViewModel, object: self, userInfo: [Plane.InfoKey.unselected: unselected as Any, Plane.InfoKey.selected: selected as Any])
    }
    
    func setSelected(to color: Color = Color.random()) {
        guard let colorMutable = selected as? ColorMutable else { return }
        colorMutable.set(to: color)
        NotificationCenter.default.post(name: Plane.Event.didSetColor, object: self, userInfo: [Plane.InfoKey.set: color])
    }
    
    func setSelected(to alpha: Alpha) {
        guard let alphaMutable = selected as? AlphaMutable else { return }
        alphaMutable.set(to: alpha)
        NotificationCenter.default.post(name: Plane.Event.didSetAlpha, object: self, userInfo: [Plane.InfoKey.set: alpha])
    }
    
    func setSelected(to text: String) {
        guard let textMutable = selected as? TextMutable else { return }
        textMutable.set(to: text)
        NotificationCenter.default.post(name: Plane.Event.didSetText, object: self, userInfo: [Plane.InfoKey.set: text])
    }
    
    func setSelected(to origin: Point) {
        guard let viewModel = selected else { return }
        viewModel.set(to: origin)
        NotificationCenter.default.post(name: Plane.Event.didSetOrigin, object: self, userInfo: [Plane.InfoKey.set: viewModel])
    }
    
    func setSelected(to size: Size) {
        guard let viewModel = selected else { return }
        viewModel.set(to: size)
        NotificationCenter.default.post(name: Plane.Event.didSetSize, object: self, userInfo: [Plane.InfoKey.set: viewModel])
    }
    
    func set(viewModel: ViewModel, to origin: Point) {
        viewModel.set(to: origin)
        NotificationCenter.default.post(name: Plane.Event.didSetOrigin, object: self, userInfo: [Plane.InfoKey.set: viewModel])
    }
    
    func set(viewModel: ViewModel, to size: Size) {
        viewModel.set(to: size)
        NotificationCenter.default.post(name: Plane.Event.didSetSize, object: self, userInfo: [Plane.InfoKey.set: viewModel])
    }
}
