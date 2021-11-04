//
// Created by David Kanenwisher on 10/24/21.
//

import Foundation
import simd

protocol GMSceneNode: RenderableNode {
    func add(child: GMSceneNode) -> GMSceneNode

    func delete(child: GMSceneNode) -> GMSceneNode

    func update(elapsed: Double) -> GMSceneNode

    func render(to: (RenderableNode) -> Void)
}

protocol CameraNode {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var transformation: float4x4 { get }

    func cameraSpace(withAspect aspect: Float) -> float4x4
}

extension GMSceneNode {
    static func +(left: GMSceneNode, right: GMSceneNode) -> GMSceneNode {
        left.add(child: right)
    }
}

func GMCreateScene() -> RenderableCollection {
   GMSceneImmutableScene(
       cameraDimensions: (1.0, 1.0)
   )
}

struct GMImmutableCamera: CameraNode {
    let cameraTop: Float
    let cameraBottom: Float
    let transformation: float4x4

    func cameraSpace(withAspect aspect: Float) -> float4x4 {
       transformation * float4x4.scaleY(aspect)
    }
}

struct GMSceneImmutableScene: RenderableCollection {
    let camera: GMImmutableCamera
    let cameraTop: Float
    let cameraBottom: Float
    let node: GMSceneNode

    init(
        node: GMSceneNode = GMSceneImmutableNode(),
        cameraDimensions: (Float, Float)
    ) {
        self.node = node
        self.camera = GMImmutableCamera(
            cameraTop: cameraDimensions.0,
            cameraBottom: cameraDimensions.1,
            transformation: float4x4.perspectiveProjection(nearPlane: 0.2, farPlane: 1.0)
        )
        self.cameraTop = cameraDimensions.0
        self.cameraBottom = cameraDimensions.1
    }

    func cameraSpace(withAspect aspect: Float) -> float4x4 {
        camera.cameraSpace(withAspect: aspect)
    }

    func click() -> RenderableCollection {

        let newNode = node.add(
            child: randomNode(children: [
                randomNode(children: [], color: Colors().red)
            ], color: Colors().green)
        ).add(child: randomNode(children: [], color: Colors().blue))

        return clone(node: newNode)
    }

    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection {
        clone(cameraDimensions: (top, bottom))
    }

    func render(to: (RenderableNode) -> Void) {
        node.render(to: to)
    }

    func update(elapsed: Double) -> RenderableCollection {
        self
    }

    private func clone(
        node: GMSceneNode? = nil,
        cameraDimensions: (Float, Float)? = nil
    ) -> RenderableCollection {
        GMSceneImmutableScene(
            node: node ?? self.node,
            cameraDimensions: cameraDimensions ?? (self.cameraTop, self.cameraBottom)
        )
    }

    private func randomNode(children: [GMSceneImmutableNode], color: float4) -> GMSceneImmutableNode {
        let location = Point(
            Float.random(in: -1...1),
            Float.random(in: self.cameraBottom...self.cameraTop),
            Float.random(in: 0...1)
        )

        let transformation = float4x4.translate(
            x: location.rawValue.x,
            y: location.rawValue.y,
            z: location.rawValue.z
        )

        return GMSceneImmutableNode(
            children: children,
            location: location,
            transformation: transformation,
            vertices: VerticeCollection().c[.cube]!,
            color: color
        )
    }
}

struct GMSceneImmutableNode: GMSceneNode {
    private let children: [GMSceneNode]

    let location: Point
    let transformation: float4x4
    let vertices: Vertices
    let color: float4

    init() {
        children = []

        location = Point.origin()
        transformation = matrix_identity_float4x4
        vertices = Vertices(
            Point(0.0, 0.0, 0.0)
        )
        color = Colors().green
    }

    init(
        children: [GMSceneNode],
        location: Point,
        transformation: float4x4,
        vertices: Vertices,
        color: float4
    ) {
        self.children = children
        self.location = location
        self.transformation = transformation
        self.vertices = vertices
        self.color = color
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

    private func clone(
        children: [GMSceneNode]? = nil,
        location: Point? = nil,
        transformation: float4x4? = nil,
        vertices: Vertices? = nil,
        color: float4? = nil
    ) -> GMSceneImmutableNode {
        GMSceneImmutableNode(
            children: children ?? self.children,
            location: location ?? self.location,
            transformation: transformation ?? self.transformation,
            vertices: vertices ?? self.vertices,
            color: color ?? self.color
        )
    }
}
