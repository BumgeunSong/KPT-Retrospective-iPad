//
//  Plane.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/02.
//

import Foundation

class Plane {
    static let addViewModel = Notification.Name("addViewModel")
    static let selectViewModel = Notification.Name("selectViewModel")
    static let mutateColorViewModel = Notification.Name("mutateColorViewModel")
    static let mutateAlphaViewModel = Notification.Name("mutateAlphaViewModel")
    static let mutateOriginViewModel = Notification.Name("mutateOriginViewModel")
    
    private var viewModels: [ViewModel] = [] {
        didSet {
            guard let newModel = viewModels.last else { return }
            viewModelIDMap[newModel.id] = newModel
            Log.info("Added: \(newModel)")
        }
    }
    
    private var viewModelIDMap = [String: ViewModel]()
    
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
        let newRectangle = Rectangle.create()
        viewModels.append(newRectangle)
        NotificationCenter.default.post(name: Plane.addViewModel, object: self, userInfo: ["new": newRectangle])
    }
    
    func addPhoto(data: Data) {
        let newPhoto = Photo.create(from: data)
        viewModels.append(newPhoto)
        NotificationCenter.default.post(name: Plane.addViewModel, object: self, userInfo: ["new": newPhoto])
    }
    
    func tap(on point: Point) {
        let oldSelected = selected
        self.selected = viewModels.last(where: { viewModel in
            viewModel.contains(point)
        })
        NotificationCenter.default.post(name: Plane.selectViewModel, object: self, userInfo: ["old": oldSelected as Any, "new": selected as Any])
    }
    
    func transform(to color: Color = Rectangle.createColor()) {
        guard let mutableViewModel = selected as? ColorMutable else { return }
        mutableViewModel.transform(to: color)
        NotificationCenter.default.post(name: Plane.mutateColorViewModel, object: self)
    }
    
    func transform(to alpha: Alpha) {
        guard let mutableViewModel = selected as? AlphaMutable else { return }
        mutableViewModel.transform(to: alpha)
        NotificationCenter.default.post(name: Plane.mutateAlphaViewModel, object: self)
    }
    
    func transform(_ id: String, to origin: Point) {
        guard let mutableViewModel = viewModelIDMap[id] as? OriginMutable else { return }
        mutableViewModel.transform(to: origin)
        NotificationCenter.default.post(name: Plane.mutateOriginViewModel, object: self, userInfo: ["mutated": mutableViewModel])
    }
}
