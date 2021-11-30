//
// Created by David Kanenwisher on 10/24/21.
//

import Foundation
import simd
import MetalKit

func GMCreateScene() -> RenderableCollection {
    let root = GMImmutableNode()

    var children: [GMImmutableNode] = []
    (0..<10).forEach { _ in
       children.append(
           GMImmutableNode(
               children: [],
               location: Point(
                   Float.random(in: -1...1),
                   Float.random(in: -1...1),
                    Float.random(in: 0...1)
               ),
               transformation: matrix_identity_float4x4,
               vertices: VerticeCollection().c[.cube]!,
               color: float4(.green),
               state: .forward,
               hidden: false
           )
       )
    }


    return GMImmutableScene(
       node: root.setChildren(children),
       camera: GMImmutableCamera.atOrigin()
    )
}

struct GMImmutableNode: GMNode {
    let children: [GMNode]

    let location: Point
    let transformation: float4x4
    let vertices: Vertices
    let color: float4
    let state: GMSceneImmutableSceneState
    let rate = Float(0.26)
    let hidden: Bool

    init() {
        children = []

        location = Point.origin()
        transformation = matrix_identity_float4x4
        vertices = Vertices(
            Point(0.0, 0.0, 0.0)
        )
        color = float4(.green)
        state = .forward
        hidden = true
    }

    init(
        children: [GMNode],
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

    func add(child: GMNode) -> GMNode {
        let newChildren = children + [child]

        return clone(children: newChildren)
    }

    func delete(child: GMNode) -> GMNode {
        self
    }

    func update(elapsed: Double) -> GMNode {
        self
    }

    func render(to: (RenderableNode) -> Void) {
        to(self)
        children.forEach{ node in node.render(to: to)}
    }

    func setChildren(_ children: [GMNode]) -> GMNode {
        clone(children: children)
    }

    func update(transform: (GMNode) -> GMNode) -> GMNode {
        let newSelf = transform(self)
        let newChildren = children.map { node in node.update(transform: transform) }

        return newSelf.setChildren(newChildren)
    }

    func move(elapsed: Double) -> GMNode {

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
            (newLocation, newTransformation) = translate(Float(elapsed) * rate, 0, 0)
        case .backward:
            (newLocation, newTransformation) = translate(-1 * Float(elapsed) * rate, 0, 0)
        }

        return clone(location: newLocation, transformation: newTransformation, state: newState)
    }

    func translate(_ transform: float4x4) -> GMNode {
        clone(transformation: self.transformation * transform)
    }

    func setColor(_ color: float4) -> GMNode {
        clone(color: color)
    }

    private func clone(
        children: [GMNode]? = nil,
        location: Point? = nil,
        transformation: float4x4? = nil,
        vertices: Vertices? = nil,
        color: float4? = nil,
        state: GMSceneImmutableSceneState? = nil,
        hidden: Bool? = nil
    ) -> GMImmutableNode {
        GMImmutableNode(
            children: children ?? self.children,
            location: location ?? self.location,
            transformation: transformation ?? self.transformation,
            vertices: vertices ?? self.vertices,
            color: color ?? self.color,
            state: state ?? self.state,
            hidden: hidden ?? self.hidden
        )
    }

    private func translate(_ x: Float, _ y: Float, _ z: Float) -> (Point, float4x4) {
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