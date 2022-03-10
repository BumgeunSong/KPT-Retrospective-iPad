//
//  Plane.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/02.
//

import Foundation

class Plane {
    enum event {
        static let addViewModel = Notification.Name("addViewModel")
        static let selectViewModel = Notification.Name("selectViewModel")
        static let mutateColorViewModel = Notification.Name("mutateColorViewModel")
        static let mutateAlphaViewModel = Notification.Name("mutateAlphaViewModel")
        static let mutateOriginViewModel = Notification.Name("mutateOriginViewModel")
    }
    
    enum InfoKey {
        static let new = "new"
        static let old = "old"
        static let mutated = "mutated"
    }
    
    private var viewModels: [ViewModel] = [] {
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
    
    var viewModelCount: Int {
        viewModels.count
    }
    
    subscript(index: Int) -> ViewModel {
        return viewModels[index]
    }
    
    func addRectangle() {
        let newRectangle = Rectangle.random()
        viewModels.append(newRectangle)
        NotificationCenter.default.post(name: Plane.event.addViewModel, object: self, userInfo: [Plane.InfoKey.new: newRectangle])
    }
    
    func addPhoto(data: Data) {
        let newPhoto = Photo.random(from: data)
        viewModels.append(newPhoto)
        NotificationCenter.default.post(name: Plane.event.addViewModel, object: self, userInfo: [Plane.InfoKey.new: newPhoto])
    }
    
    func tap(on point: Point) {
        let oldSelected = selected
        self.selected = viewModels.last(where: { viewModel in
            viewModel.contains(point)
        })
        NotificationCenter.default.post(name: Plane.event.selectViewModel, object: self, userInfo: [Plane.InfoKey.old: oldSelected as Any, Plane.InfoKey.new: selected as Any])
    }
    
    func set(to color: Color = Color.random()) {
        guard let mutableViewModel = selected as? ColorMutable else { return }
        mutableViewModel.set(to: color)
        NotificationCenter.default.post(name: Plane.event.mutateColorViewModel, object: self, userInfo: [Plane.InfoKey.new: color])
    }
    
    func set(to alpha: Alpha) {
        guard let mutableViewModel = selected as? AlphaMutable else { return }
        mutableViewModel.set(to: alpha)
        NotificationCenter.default.post(name: Plane.event.mutateAlphaViewModel, object: self, userInfo: [Plane.InfoKey.new: alpha])
    }
    
    func set(viewModel: ViewModel, to origin: Point) {
        viewModel.set(to: origin)
        NotificationCenter.default.post(name: Plane.event.mutateOriginViewModel, object: self, userInfo: [Plane.InfoKey.mutated: viewModel])
    }
}
