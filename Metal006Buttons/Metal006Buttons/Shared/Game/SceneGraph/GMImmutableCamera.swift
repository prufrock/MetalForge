//
// Created by David Kanenwisher on 11/29/21.
//

import simd

struct GMImmutableCamera: GMCameraNode {
    let nearPlane: Float = 0.1
    let cameraTop: Float
    let cameraBottom: Float
    let transformation: float4x4

    // GMSceneNode
    let children: [GMNode]
    let location: Point
    let vertices: Vertices
    let color: float4
    let hidden: Bool

    static func atOrigin() -> GMImmutableCamera {
        let button1 = GMImmutableNode(
            children: [],
            location: Point(-0.5, -2.5, 0.0),
            transformation: float4x4.translate(x: -0.5, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: float4(.white),
            state: .forward,
            hidden: false
        )

        let button2 = GMImmutableNode(
            children: [],
            location: Point(0.0, -2.5, 0.0),
            transformation: float4x4.translate(x: 0.0, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: float4(.white),
            state: .forward,
            hidden: false
        )

        let button3 = GMImmutableNode(
            children: [],
            location: Point(0.5, -2.5, 0.0),
            transformation: float4x4.translate(x: 0.5, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: float4(.white),
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
            color: float4(.black),
            hidden: true
        )
    }

    func cameraSpace(withAspect aspect: Float) -> float4x4 {
        projectionMatrix(aspect) * viewMatrix()
    }

    private func viewMatrix() -> float4x4 {
        (transformation).inverse
    }

    func projectionMatrix(_ aspect: Float) -> float4x4 {
        (float4x4.perspectiveProjection(nearPlane: nearPlane, farPlane: 1.0) * float4x4.scaleY(aspect))
    }

    func reverseProjectionMatrix(_ aspect: Float) -> float4x4 {
        projectionMatrix(aspect).inverse
    }

    func translate(x: Float, y: Float, z: Float) -> GMImmutableCamera {
        let transform = float4x4.translate(x: x, y: y, z: z)
        return clone(
            transformation: self.transformation * transform,
            children: children.map{ node in node.translate(transform) }
        )
    }

    func setDimensions(cameraTop: Float, cameraBottom: Float) -> GMImmutableCamera {
        clone(cameraTop: cameraTop, cameraBottom: cameraBottom)
    }

    func add(child: GMNode) -> GMNode {
        clone(children: children + [child])
    }

    func delete(child: GMNode) -> GMNode {
        self
    }

    func update(transform: (GMNode) -> GMNode) -> GMNode {
        self
    }

    func setColor(_ color: float4) -> GMNode {
        self
    }

    func setChildren(_ children: [GMNode]) -> GMNode {
        clone(children: children)
    }

    func move(elapsed: Double) -> GMNode {
        self
    }

    func translate(_ transform: float4x4) -> GMNode {
        clone(transformation: transform)
    }

    func render(to: (RenderableNode) -> Void) {
        to(self)
        children.forEach{ node in node.render(to: to)}
    }

    func clone(
        cameraTop: Float? = nil,
        cameraBottom: Float? = nil,
        transformation: float4x4? = nil,
        children: [GMNode]? = nil,
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
