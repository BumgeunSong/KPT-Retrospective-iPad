# KPT 회고 앱
by Eddy

## Screenshot
![](https://user-images.githubusercontent.com/17468015/160514732-5f9ba8e3-165b-46ea-bb91-ff21f274aa46.png)

## 주요 기능
* 레이어 생성: 캔버스에 사각형, 사진, 텍스트, 포스트잇을 추가할 수 있다.
* 선택 및 드래그: 레이어를 탭으로 선택하고, 드래그해서 위치를 옮길 수 있다.
* 패널로 속성 변경: 각 레이어의 속성을 패널에서 변경할 수 있다.
* 레이어 리스트: 레이어 리스트에서 레이어를 선택하고 순서를 바꿀 수 있다.


# 주요 고민 및 구현

## MVVM 리팩토링
* 초반 MVC 구조 설계 후 MVVM 구조로 리팩토링. 
* ViewController가 가지고 있던 Presentation logic을 뷰 모델로 분리. 
* 도메인 모델인 Plane이 가지고 있던 Add, Select 등의 비즈니스 로직을 Service로 분리.
* CanvasViewModel이 CanvasView의 추상화 상태(State)를 저장

![](https://user-images.githubusercontent.com/17468015/160997465-fe851675-028f-4738-951c-d5d31beb7d22.png)


## 바인딩 메커니즘 구현
* 커스텀 Observable을 구현해 ViewModel과 View를 바인딩.

```swift

class Observable<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}

```


## 팩토리 패턴으로 생성과 사용을 분리
* 팩토리 메서드를 사용해 Layer와 View를 생성. Layer를 생성하는 AddService가 생성 로직을 몰라도 되도록 추상화함.

```swift
enum LayerFactory {
    static func makeRandom<T: Layer>(_ type: T.Type, titleOrder: Int, from data: Data? = nil) -> Layer? {
        let ID = ID.random()
        let origin = Point.random()
        let size = Size.standard()
        let alpha = Alpha(Alpha.max)!
        
        switch type {
        case is Rectangle.Type:
            let color = Color.random()
            return Rectangle(title: "Rect \(titleOrder)", id: ID, origin: origin, size: size, color: color, alpha: alpha)
        case is Photo.Type:
            guard let data = data else { return nil }
            return Photo(title: "\(Photo.self) \(titleOrder)", id: ID, origin: origin, size: size, photo: data, alpha: alpha)
        case is Label.Type:
            let text = dummyString()
            let fontSize = Float.random(in: 16...32)
            return Label(title: "\(Label.self) \(titleOrder)", id: ID, origin: origin, size: size, text: text, fontSize: fontSize)
        case is PostIt.Type:
            let text = defaultString
            let color = Color.random()
            return PostIt(title: "\(PostIt.self) \(titleOrder)", id: ID, origin: origin, size: size, text: text, color: color)
        default:
            return nil
        }
    }
}

```


## 의존성 역전 & 주입
* 프로토콜 `LayerAddable`, `LayerSelectable`, `LayerContainable`  사용해 ViewModel과 모델 사이의 의존성을 역전. 
* SceneDelegate에서 DI 컨테이너를 생성하고 전달해 의존성을 주입.

![](https://user-images.githubusercontent.com/17468015/160997465-fe851675-028f-4738-951c-d5d31beb7d22.png)

```swift

protocol LayerContainable: AnyObject {
    var layers: [Layer] { get set }
    var selected: Layer? { get set }
}

class PassivePlane: LayerContainable {
    static let shared = PassivePlane() as LayerContainable
    
    var layers: [Layer]
    var selected: Layer?
    
    init(layers: [Layer] = [], selected: Layer? = nil) {
        self.layers = layers
        self.selected = selected
    }
}

```

```swift
protocol LayerAddable {
    func add<T: Layer>(type: T.Type, imageData: Data?, onAdd: onAddHandler)
}

struct AddService: LayerAddable {
    
    var layerContainable: LayerContainable?
    
    init(layerContainable: LayerContainable?) {
        self.layerContainable = layerContainable
    }
      // ...
```

```swift
typealias onSelectHandler = ((Layer?, Layer?) -> Void)?

protocol LayerSelectable {
    func select(on point: Point, onSelect: onSelectHandler)
}

struct SelectService: LayerSelectable {
    
    var layerContainable: LayerContainable?
    
    init(layerContainable: LayerContainable?) {
        self.layerContainable = layerContainable
    }
    // ...
```

```swift
class CanvasViewModel {
    let layerAddable: LayerAddable?
    let newView = Observable<UIView?>(nil)
    
    let layerSelectable: LayerSelectable?
    let selectedView = Observable<UIView?>(nil)
    let unselectedView = Observable<UIView?>(nil)
    
    var layerDict = [Layer: UIView]()
    
    init(layerAddable: LayerAddable?, layerSelectable: LayerSelectable?) {
        self.layerAddable = layerAddable
        self.layerSelectable = layerSelectable
    }
      // ...
```


```swift
private let container: DIContainable = {
        let container = DIContainer()
        
        container.register(type: LayerContainable.self) {
            _ in PassivePlane.shared
        }

        container.register(type: LayerAddable.self) { _ in
            AddService(
                layerContainable: container.resolve(
                    type: LayerContainable.self
                )
            ) as AnyObject }

        container.register(type: LayerSelectable.self) { _ in
            SelectService(
                layerContainable: container.resolve(type: LayerContainable.self)
            ) as AnyObject }
        
        container.register(type: CanvasViewModel.self) { container in
            CanvasViewModel(
                layerAddable: container.resolve(
                    type: LayerAddable.self
                ),
                layerSelectable: container.resolve(
                    type: LayerSelectable.self
                )
            )
        }
        
        return container
    }()
```


** 서드파티 라이브러리 대신 간단한 DI Container를 직접 구현

```swift
typealias FactoryClosure = (DIContainer) -> AnyObject

protocol DIContainable {
    func register<Service>(type: Service.Type, factoryClosure: @escaping FactoryClosure)
    func resolve<Service>(type: Service.Type) -> Service?
}

class DIContainer: DIContainable {
    var services = Dictionary<String, FactoryClosure>()
    
    func register<Service>(type: Service.Type, factoryClosure: @escaping FactoryClosure) {
        services["\(type)"] = factoryClosure
    }
    
    func resolve<Service>(type: Service.Type) -> Service? {
        return services["\(type)"]?(self) as? Service
    }
}
```

** 런타임 시점에 DIContainer를 사용해 객체를 조합

```swift
private let container: DIContainable = {
        let container = DIContainer()
        
        container.register(type: LayerContainable.self) {
            _ in PassivePlane.shared
        }

        container.register(type: LayerAddable.self) { _ in
            AddService(
                layerContainable: container.resolve(
                    type: LayerContainable.self
                )
            ) as AnyObject }

        container.register(type: LayerSelectable.self) { _ in
            SelectService(
                layerContainable: container.resolve(type: LayerContainable.self)
            ) as AnyObject }
        
        container.register(type: CanvasViewModel.self) { container in
            CanvasViewModel(
                layerAddable: container.resolve(
                    type: LayerAddable.self
                ),
                layerSelectable: container.resolve(
                    type: LayerSelectable.self
                )
            )
        }
        
        return container
    }()
```


## 인터페이스 분리
- 프로토콜을 사용해 속성 변경을 추상화하고 인터페이스를 분리.
- 컬러와 알파를 둘다 바꿀 수 있는 Rectangle, 알파만 바꿀 수 있는 TextMutable, 텍스트만 바꿀 수 있는 TextMutable로 설정. 
- 각각 클라이언트가 사용하지 않는 인터페이스는 포함하지 않도록 분리. 

```swift
protocol ColorMutable {
    var color: Color { get }
    func set(to color: Color)
}

protocol AlphaMutable {
    var alpha: Alpha { get }
    func set(to alpha: Alpha)
}

protocol TextMutable {
    var getText: String { get }
    func set(to text: String)
}
```

```swift
class Rectangle: Layer {
    
    private(set) var color: Color
    private(set) var alpha: Alpha
    
    init(title: String, id: ID, origin: Point, size: Size, color: Color, alpha: Alpha) {
        self.color = color
        self.alpha = alpha
        super.init(title: title, id: id, origin: origin, size: size)
    }
}

extension Rectangle: ColorMutable {
    func set(to color: Color) {
        self.color = color
    }
}

extension Rectangle: AlphaMutable {
    func set(to alpha: Alpha) {
        self.alpha = alpha
    }
}
```

```swift
class Photo: Layer {
    
    private(set) var data: Data
    private(set) var alpha: Alpha

    init(title: String, id: ID, origin: Point, size: Size, photo: Data, alpha: Alpha) {
        self.data = photo
        self.alpha = alpha
        super.init(title: title, id: id, origin: origin, size: size)
    }
}

extension Photo: AlphaMutable {
    func set(to alpha: Alpha) {
        self.alpha = alpha
    }
}
   
```

```swift
class Label: Layer {
    private(set) var getText: String
    private(set) var fontSize: Float
    
    init(title: String, id: ID, origin: Point, size: Size, text: String, fontSize: Float) {
        self.getText = text
        self.fontSize = fontSize
        super.init(title: title, id: id, origin: origin, size: size)
    }
}

extension Label: TextMutable {
    func set(to text: String) {
        self.getText = text
    }
}
```

## GestureRecognizer를 활용해 드래그 구현
- 특정 뷰를 드래그했을 때 반투명한 임시 뷰가 생성되어 따라오도록 구현.
- 드래그를 끝내면 임시 뷰는 사라지고 새로운 위치로 이동. 

![step5](https://user-images.githubusercontent.com/17468015/157000787-c752f420-b6d7-4f26-bf3d-17f9a0e108c8.gif)


```swift
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        startPan(gesture)
        drag(gesture)
        endPan(gesture)
    }
    
    private func startPan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view,
              gesture.state == .began else { return }
        
        guard let temporaryView = gestureView.copy() as? UIView else { return }
        
        self.temporaryView = temporaryView
        canvasView?.addSubview(temporaryView)
    }
    
    private func drag(_ gesture: UIPanGestureRecognizer) {
        guard let temporaryView = temporaryView else { return }
        
        let translation = gesture.translation(in: view)
        temporaryView.center = CGPoint(
            x: temporaryView.center.x + translation.x,
            y: temporaryView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: view)
        didMoveTemporaryView?(temporaryView)
    }

    private func endPan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view,
              let gestureLayer = viewMap[gestureView],
              let temporaryView = temporaryView,
              gesture.state == .ended else { return }
        
        let lastOrigin = Point(x: temporaryView.frame.origin.x,
                               y: temporaryView.frame.origin.y)
        
        plane.change(layer: gestureLayer, toOrigin: lastOrigin)
        temporaryView.removeFromSuperview()
    }
    
    private func search(for view: UIView) -> Layer? {
        return viewMap[view]
    }
```
