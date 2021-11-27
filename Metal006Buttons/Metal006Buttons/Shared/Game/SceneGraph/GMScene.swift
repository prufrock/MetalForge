//
// Created by David Kanenwisher on 10/24/21.
//

import Foundation
import simd
import MetalKit

protocol GMSceneNode: RenderableNode {
    var children: [GMSceneNode] { get }

    func add(child: GMSceneNode) -> GMSceneNode

    func delete(child: GMSceneNode) -> GMSceneNode

    func update(transform: (GMSceneNode) -> GMSceneNode) -> GMSceneNode

    func setColor(_ color: float4) -> GMSceneNode

    func setChildren(_ children: [GMSceneNode]) -> GMSceneNode

    func move(elapsed: Double) -> GMSceneNode

    func render(to: (RenderableNode) -> Void)

    func translate(_ transform: float4x4) -> GMSceneNode
}

protocol CameraNode: GMSceneNode {
    var cameraTop: GMFloat { get }
    var cameraBottom: GMFloat { get }
    var transformation: float4x4 { get }
    var nearPlane: GMFloat { get }

    func cameraSpace(withAspect aspect: GMFloat) -> float4x4

    func projectionMatrix(_ aspect: GMFloat) -> float4x4

    func reverseProjectionMatrix(_ aspect: GMFloat) -> float4x4
}

extension GMSceneNode {
    static func +(left: GMSceneNode, right: GMSceneNode) -> GMSceneNode {
        left.add(child: right)
    }
}

func GMCreateScene() -> RenderableCollection {
    let root = GMSceneImmutableNode()

    var children: [GMSceneImmutableNode] = []
    (0..<10).forEach { _ in
       children.append(
           GMSceneImmutableNode(
               children: [],
               location: Point(
                   GMFloat.random(in: -1...1),
                   GMFloat.random(in: -1...1),
                    GMFloat.random(in: 0...1)
               ),
               transformation: matrix_identity_float4x4,
               vertices: VerticeCollection().c[.cube]!,
               color: Colors().green,
               state: .forward,
               hidden: false
           )
       )
    }


    return GMSceneImmutableScene(
       node: root.setChildren(children),
       camera: GMImmutableCamera.atOrigin()
    )
}

struct GMImmutableCamera: CameraNode {
    let nearPlane: GMFloat = 0.1
    let cameraTop: GMFloat
    let cameraBottom: GMFloat
    let transformation: float4x4

    // GMSceneNode
    let children: [GMSceneNode]
    let location: Point
    let vertices: Vertices
    let color: float4
    let hidden: Bool

    static func atOrigin() -> GMImmutableCamera {
        let button1 = GMSceneImmutableNode(
            children: [],
            location: Point(-0.5, -2.5, 0.0),
            transformation: float4x4.translate(x: -0.5, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: Colors().white,
            state: .forward,
            hidden: false
        )

        let button2 = GMSceneImmutableNode(
            children: [],
            location: Point(0.0, -2.5, 0.0),
            transformation: float4x4.translate(x: 0.0, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: Colors().white,
            state: .forward,
            hidden: false
        )

        let button3 = GMSceneImmutableNode(
            children: [],
            location: Point(0.5, -2.5, 0.0),
            transformation: float4x4.translate(x: 0.5, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: Colors().white,
            state: .forward,
            hidden: false
        )


        return GMImmutableCamera(
            cameraTop: 1.0,
            cameraBottom: 1.0,
            transformation: matrix_identity_float4x4,
            children: [button1, button2, button3],
            location: Point.origin(),
            vertices: Vertices(),
            color: Colors().black,
            hidden: true
        )
    }

    func cameraSpace(withAspect aspect: GMFloat) -> float4x4 {
        projectionMatrix(aspect) * viewMatrix()
    }

    private func viewMatrix() -> float4x4 {
        (transformation).inverse
    }

    func projectionMatrix(_ aspect: GMFloat) -> float4x4 {
        (float4x4.perspectiveProjection(nearPlane: nearPlane, farPlane: 1.0) * float4x4.scaleY(aspect))
    }

    func reverseProjectionMatrix(_ aspect: GMFloat) -> float4x4 {
        projectionMatrix(aspect).inverse
    }

    func translate(x: GMFloat, y: GMFloat, z: GMFloat) -> GMImmutableCamera {
        let transform = float4x4.translate(x: x, y: y, z: z)
        return clone(
            transformation: self.transformation * transform,
            children: children.map{ node in node.translate(transform) }
        )
    }

    func setDimensions(cameraTop: GMFloat, cameraBottom: GMFloat) -> GMImmutableCamera {
        clone(cameraTop: cameraTop, cameraBottom: cameraBottom)
    }

    func add(child: GMSceneNode) -> GMSceneNode {
        clone(children: children + [child])
    }

    func delete(child: GMSceneNode) -> GMSceneNode {
        self
    }

    func update(transform: (GMSceneNode) -> GMSceneNode) -> GMSceneNode {
        self
    }

    func setColor(_ color: float4) -> GMSceneNode {
        self
    }

    func setChildren(_ children: [GMSceneNode]) -> GMSceneNode {
        clone(children: children)
    }

    func move(elapsed: Double) -> GMSceneNode {
        self
    }

    func translate(_ transform: float4x4) -> GMSceneNode {
        clone(transformation: transform)
    }

    func render(to: (RenderableNode) -> Void) {
        to(self)
        children.forEach{ node in node.render(to: to)}
    }

    func clone(
        cameraTop: GMFloat? = nil,
        cameraBottom: GMFloat? = nil,
        transformation: float4x4? = nil,
        children: [GMSceneNode]? = nil,
        location: Point? = nil,
        vertices: Vertices? = nil,
        color: float4? = nil,
        hidden: Bool? = nil
        ) -> GMImmutableCamera {
        GMImmutableCamera(
            cameraTop: cameraTop ?? self.cameraTop,
            cameraBottom: cameraBottom ?? self.cameraBottom,
            transformation: transformation ?? self.transformation,
            children: children ?? self.children,
            location: location ?? self.location,
            vertices: vertices ?? self.vertices,
            color: color ?? self.color,
            hidden: hidden ?? self.hidden
        )
    }
}

struct GMSceneImmutableScene: RenderableCollection {
    private let screenHeight: CGFloat
    private let screenWidth: CGFloat

    let camera: GMImmutableCamera
    let node: GMSceneNode
    let state: SceneState

    init(
        node: GMSceneNode = GMSceneImmutableNode(),
        camera: GMImmutableCamera,
        state: SceneState = .paused,
        screenWidth: CGFloat = 0,
        screenHeight: CGFloat = 0
    ) {
        self.node = node
        self.camera = camera
        self.state = state
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    }

    func cameraSpace(withAspect aspect: GMFloat) -> float4x4 {
        camera.cameraSpace(withAspect: aspect)
    }

    func click() -> RenderableCollection {
        self.clone(camera: self.camera.translate(x: 0.1, y: 0.0, z: 0.0))
    }

    func click(x: CGFloat, y: CGFloat) -> RenderableCollection {
        let aspect = GMFloat(screenWidth / screenHeight)
        let displayCoords = SIMD2<GMFloat>(GMFloat(x), GMFloat(y))
        let ndcCoords: float4x4 = displayCoords.displayToNdc(
            display: SIMD2<GMFloat>(GMFloat(screenWidth), GMFloat(screenHeight))
        )

        let worldCoords = ndcCoords * camera.reverseProjectionMatrix(aspect)

        let ray = Ray(origin: float3(worldCoords[0][0], worldCoords[1][1], 0.0), target: float3(worldCoords[0][0], worldCoords[1][1], camera.nearPlane))

        var newChildren: [GMSceneNode] = []

        for i in 0..<camera.children.count {
            let children = camera.children
            let node = children[i]
            let sphere = Sphere(center: node.location.rawValue, radius: 0.2)
            if(ray.intersects(with: sphere)) {
                if (node.color == Colors().white) {
                    newChildren.append(node.setColor(Colors().red))
                } else {
                    newChildren.append(node.setColor(Colors().white))
                }
            } else {
                newChildren.append(node)
            }
        }

        return self.clone(camera: camera.clone(children: newChildren))
    }

    func setCameraDimension(top: GMFloat, bottom: GMFloat) -> RenderableCollection {
        clone(
            camera: camera.setDimensions(cameraTop: top, cameraBottom: bottom)
        )
    }

    func render(to: (RenderableNode) -> Void) {
        camera.render(to: to)
        node.render(to: to)
    }

    func update(elapsed: Double) -> RenderableCollection {
        var newNode: GMSceneNode
        switch state {
        case .playing:
            newNode = node.setChildren(node.children.map {
                node in node.update { node in
                    node.move(elapsed: elapsed).setColor(Colors().green)
                }
            })
        case .paused:
            newNode = node.setChildren(updateAllButNewestChild(elapsed: elapsed, children: node.children))
        }

        if(newNode.children.count >= 1) {
            newNode = newNode.setChildren(newNode.children[0..<(node.children.endIndex-1)] + [newNode.children.last!.setColor(Colors().red)])
        }

        return clone(node: newNode)
    }

    private func updateAllButNewestChild(
        elapsed: Double,
        children oldChildren: [GMSceneNode],
        newChildren: [GMSceneNode] = []
    ) -> [GMSceneNode] {
        // if there's no children then do nothing
        if oldChildren.lastIndex == -1 {
            return oldChildren
        // stop just short of the end so that the last element doesn't change
        } else if (newChildren.lastIndex + 1) == oldChildren.lastIndex {
            return newChildren + [oldChildren[oldChildren.lastIndex]]
        } else {
            return updateAllButNewestChild(elapsed: elapsed, children: oldChildren, newChildren: newChildren + [oldChildren[newChildren.count].move(elapsed: elapsed).setColor(Colors().green)])
        }
    }

    private func clone(
        node: GMSceneNode? = nil,
        camera: GMImmutableCamera? = nil,
        state: SceneState? = nil,
        screenWidth: CGFloat? = nil,
        screenHeight: CGFloat? = nil
    ) -> RenderableCollection {
        GMSceneImmutableScene(
            node: node ?? self.node,
            camera: camera ?? self.camera,
            state: state ?? self.state,
            screenWidth: screenWidth ?? self.screenWidth,
            screenHeight: screenHeight ?? self.screenHeight
        )
    }

    func setScreenDimensions(height: CGFloat, width: CGFloat) -> RenderableCollection {
        return clone(screenWidth: width, screenHeight: height)
    }

    private func randomNode(children: [GMSceneImmutableNode], color: float4) -> GMSceneImmutableNode {
        let location = Point(
            GMFloat.random(in: -1...1),
            GMFloat.random(in: self.camera.cameraBottom...self.camera.cameraTop),
            GMFloat.random(in: 0...1)
        )

        let transformation = matrix_identity_float4x4

        return GMSceneImmutableNode(
            children: children,
            location: location,
            transformation: transformation,
            vertices: VerticeCollection().c[.cube]!,
            color: color,
            state: .forward,
            hidden: false
        )
    }

    enum SceneState {
        case playing
        case paused
    }
}

struct GMSceneImmutableNode: GMSceneNode {
    let children: [GMSceneNode]

    let location: Point
    let transformation: float4x4
    let vertices: Vertices
    let color: float4
    let state: GMSceneImmutableSceneState
    let rate = GMFloat(0.26)
    let hidden: Bool

    init() {
        children = []

        location = Point.origin()
        transformation = matrix_identity_float4x4
        vertices = Vertices(
            Point(0.0, 0.0, 0.0)
        )
        color = Colors().green
        state = .forward
        hidden = true
    }

    init(
        children: [GMSceneNode],
        location: Point,
        transformation: float4x4,
        vertices: Vertices,
        color: float4,
        state: GMSceneImmutableSceneState,
        hidden: Bool
    ) {
        self.children = children
        self.location = location
        self.transformation = transformation
        self.vertices = vertices
        self.color = color
        self.state = state
        self.hidden = hidden
    }

    func add(child: GMSceneNode) -> GMSceneNode {
        let newChildren = children + [child]

        return clone(children: newChildren)
    }

    func delete(child: GMSceneNode) -> GMSceneNode {
        self
    }

    func update(elapsed: Double) -> GMSceneNode {
        self
    }

    func render(to: (RenderableNode) -> Void) {
        to(self)
        children.forEach{ node in node.render(to: to)}
    }

    func setChildren(_ children: [GMSceneNode]) -> GMSceneNode {
        clone(children: children)
    }

    func update(transform: (GMSceneNode) -> GMSceneNode) -> GMSceneNode {
        let newSelf = transform(self)
        let newChildren = children.map { node in node.update(transform: transform) }

        return newSelf.setChildren(newChildren)
    }

    func move(elapsed: Double) -> GMSceneNode {

        let newState: GMSceneImmutableSceneState
        if (location.rawValue.x > 1) {
            newState = .backward
        } else if (location.rawValue.x < -1) {
            newState = .forward
        } else {
            newState = state
        }

        let newLocation: Point
        let newTransformation: float4x4
        switch state {
        case .forward:
            (newLocation, newTransformation) = translate(GMFloat(elapsed) * rate, 0, 0)
        case .backward:
            (newLocation, newTransformation) = translate(-1 * GMFloat(elapsed) * rate, 0, 0)
        }

        return clone(location: newLocation, transformation: newTransformation, state: newState)
    }

    func translate(_ transform: float4x4) -> GMSceneNode {
        clone(transformation: self.transformation * transform)
    }

    func setColor(_ color: float4) -> GMSceneNode {
        clone(color: color)
    }

    private func clone(
        children: [GMSceneNode]? = nil,
        location: Point? = nil,
        transformation: float4x4? = nil,
        vertices: Vertices? = nil,
        color: float4? = nil,
        state: GMSceneImmutableSceneState? = nil,
        hidden: Bool? = nil
    ) -> GMSceneImmutableNode {
        GMSceneImmutableNode(
            children: children ?? self.children,
            location: location ?? self.location,
            transformation: transformation ?? self.transformation,
            vertices: vertices ?? self.vertices,
            color: color ?? self.color,
            state: state ?? self.state,
            hidden: hidden ?? self.hidden
        )
    }

    private func translate(_ x: GMFloat, _ y: GMFloat, _ z: GMFloat) -> (Point, float4x4) {
        let newLocation = location.translate(x, y, z)
        let newTransformation = float4x4.translate(
            x: location.rawValue.x + x,
            y: location.rawValue.y + y,
            z: location.rawValue.z + z
        )

        return (newLocation, newTransformation)
    }

    enum GMSceneImmutableSceneState {
        case forward
        case backward
    }
}