//
// Created by David Kanenwisher on 11/29/21.
//

import simd

struct GMImmutableNode: GMNode, RenderableNode {
    var element: RenderableNode {
        get {
            self
        }
    }

    let children: [GMNode]

    let location: Point
    let transformation: Float4x4
    let vertices: Vertices
    let color: Float4
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
        color = Float4(.green)
        state = .forward
        hidden = true
    }

    init(
        children: [GMNode],
        location: Point,
        transformation: Float4x4,
        vertices: Vertices,
        color: Float4,
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
        to(element)
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

    func move(elapsed: Double) -> RenderableNode {

        let newState: GMSceneImmutableSceneState
        if (location.rawValue.x > 1) {
            newState = .backward
        } else if (location.rawValue.x < -1) {
            newState = .forward
        } else {
            newState = state
        }

        let newLocation: Point
        let newTransformation: Float4x4
        switch state {
        case .forward:
            (newLocation, newTransformation) = translate(Float(elapsed) * rate, 0, 0)
        case .backward:
            (newLocation, newTransformation) = translate(-1 * Float(elapsed) * rate, 0, 0)
        }

        return clone(location: newLocation, transformation: newTransformation, state: newState)
    }

    func translate(_ transform: Float4x4) -> GMNode {
        clone(transformation: self.transformation * transform)
    }

    func setColor(_ color: Float4) -> RenderableNode {
        clone(color: color)
    }

    private func clone(
        children: [GMNode]? = nil,
        location: Point? = nil,
        transformation: Float4x4? = nil,
        vertices: Vertices? = nil,
        color: Float4? = nil,
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

    private func translate(_ x: Float, _ y: Float, _ z: Float) -> (Point, Float4x4) {
        let newLocation = location.translate(x, y, z)
        let newTransformation = Float4x4.translate(
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