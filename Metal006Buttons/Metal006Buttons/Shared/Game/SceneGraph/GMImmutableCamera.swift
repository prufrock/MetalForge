//
// Created by David Kanenwisher on 11/29/21.
//

import simd

struct GMImmutableCamera: GMCameraNode, RenderableNode {
    var element: RenderableNode {
        get {
            self
        }
    }
    let nearPlane: Float = 0.1
    var cameraTop: Float {
        get {
            1 / aspectRatio
        }
    }
    var cameraBottom: Float {
        get {
            -1 * (1 / aspectRatio)
        }
    }
    let transformation: Float4x4
    let aspectRatio: Float

    let cameraTransformMatrix: Float4x4

    // GMSceneNode
    let children: [GMNode]
    let location: Point
    let vertices: Vertices
    let color: Float4
    let hidden: Bool

    init(
        transformation: Float4x4,
        aspectRatio: Float,
        children: [GMNode],
        location: Point,
        vertices: Vertices,
        color: Float4,
        hidden: Bool,
        cameraTransformMatrix: Float4x4 = Float4x4.perspectiveProjection(nearPlane: 0.1, farPlane: 1.0)
    ) {
        self.transformation = transformation
        self.children = children
        self.location = location
        self.vertices = vertices
        self.color = color
        self.hidden = hidden
        self.aspectRatio = aspectRatio
        self.cameraTransformMatrix = cameraTransformMatrix
    }

    static func atOrigin() -> GMImmutableCamera {
        let button1 = GMImmutableNode(
            children: [],
            location: Point(-0.5, -2.5, 0.0),
            transformation: Float4x4.translate(x: -0.5, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: Float4(.white),
            state: .forward,
            hidden: false
        )

        let button2 = GMImmutableNode(
            children: [],
            location: Point(0.0, -2.5, 0.0),
            transformation: Float4x4.translate(x: 0.0, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: Float4(.white),
            state: .forward,
            hidden: false
        )

        let button3 = GMImmutableNode(
            children: [],
            location: Point(0.5, -2.5, 0.0),
            transformation: Float4x4.translate(x: 0.5, y: -2.5, z: 0.0),
            vertices: VerticeCollection().c[.square]!,
            color: Float4(.white),
            state: .forward,
            hidden: false
        )

        let button4 = GMImmutableNode(
            children: [],
            location: Point(0.5, -0.5, 0.0),
            transformation: (Float4x4.translate(x: 0.5, y: -0.5, z: 0.0)),
            vertices: VerticeCollection().c[.square]!,
            color: Float4(.white),
            state: .forward,
            hidden: false
        )


        return GMImmutableCamera(
            transformation: matrix_identity_float4x4,
            aspectRatio: 1.0,
            children: [button1, button2, button3, button4],
            location: Point.origin(),
            vertices: Vertices(),
            color: Float4(.black),
            hidden: true
        )
    }

    func cameraSpace() -> Float4x4 {
        projectionMatrix() * viewMatrix()
    }

    private func viewMatrix() -> Float4x4 {
        (transformation).inverse
    }

    //TODO rename
    func projectionMatrix() -> Float4x4 {
        (cameraTransformMatrix * Float4x4.scaleY(aspectRatio))
    }

    func reverseProjectionMatrix() -> Float4x4 {
        projectionMatrix().inverse
    }

    func orthographicMatrix() -> Float4x4 {
        Float4x4.orthographicProjection() * Float4x4.scaleY(aspectRatio)
    }

    func reverseOrthographicMatrix() -> Float4x4 {
        orthographicMatrix().inverse
    }

    func setCameraTransformMatrix(cameraTransformMatrix: Float4x4) -> Self {
        self.clone(cameraTransformMatrix: cameraTransformMatrix)
    }

    //TODO promote to interface
    func setAspectRatio(_ aspectRatio: Float) -> Self {
        clone(aspectRatio: aspectRatio)
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

    func setColor(_ color: Float4) -> RenderableNode {
        self
    }

    func setChildren(_ children: [GMNode]) -> GMNode {
        clone(children: children)
    }

    func move(elapsed: Double) -> RenderableNode {
        self
    }

    func translate(_ transform: Float4x4) -> RenderableNode {
        clone(
            transformation: self.transformation * transform,
            children: children.map{ node in
                if let translatedNode = node.element.translate(transform) as? GMNode {
                    return translatedNode
                } else {
                    return node
                }
            }
        )
    }

    func render(to: (RenderableNode) -> Void) {
        to(self)
        children.forEach{ node in node.render(to: to)}
    }

    func clone(
        transformation: Float4x4? = nil,
        children: [GMNode]? = nil,
        location: Point? = nil,
        vertices: Vertices? = nil,
        color: Float4? = nil,
        hidden: Bool? = nil,
        aspectRatio: Float? = nil,
        cameraTransformMatrix: Float4x4? = nil
    ) -> GMImmutableCamera {
        GMImmutableCamera(
            transformation: transformation ?? self.transformation,
            aspectRatio: aspectRatio ?? self.aspectRatio,
            children: children ?? self.children,
            location: location ?? self.location,
            vertices: vertices ?? self.vertices,
            color: color ?? self.color,
            hidden: hidden ?? self.hidden,
            cameraTransformMatrix: cameraTransformMatrix ?? self.cameraTransformMatrix
        )
    }
}
