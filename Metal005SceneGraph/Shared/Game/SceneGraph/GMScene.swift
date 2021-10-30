//
// Created by David Kanenwisher on 10/24/21.
//

import Foundation
import simd

protocol GMSceneNode: RenderableNode {
    func add(child: GMSceneNode) -> GMSceneNode


    func delete(child: GMSceneNode) -> GMSceneNode

    func update(elapsed: Double) -> GMSceneNode
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

struct GMSceneImmutableScene: RenderableCollection {
    let cameraTop: Float
    let cameraBottom: Float
    let node: GMSceneNode

    init(
        node: GMSceneNode = GMSceneImmutableNode(),
        cameraDimensions: (Float, Float)
    ) {
        self.node = node
        self.cameraTop = cameraDimensions.0
        self.cameraBottom = cameraDimensions.1
    }

    func click() -> RenderableCollection {

        let newNode = node.add(
            child: GMSceneImmutableNode(
                parent: node, //not correct
                children: [],
                location: Point(
                    Float.random(in: -1...1),
                    Float.random(in: self.cameraBottom...self.cameraTop),
                    Float.random(in: 0...1)
                ),
                transformation: matrix_identity_float4x4,
                vertices: VerticeCollection().c[.cube]!,
                color: Colors().green
            )
        )

        return clone(node: newNode)
    }

    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection {
        self
    }

    func render(to: (RenderableNode) -> Void) {
        to(node)
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
}

struct GMSceneImmutableNode: GMSceneNode {
    let parent: GMSceneNode?
    let children: [GMSceneNode]

    let location: Point
    let transformation: float4x4
    let vertices: Vertices
    let color: float4

    init() {
        parent = nil
        children = []

        location = Point.origin()
        transformation = matrix_identity_float4x4
        vertices = Vertices(
            Point(0.0, 0.0, 0.0)
        )
        color = Colors().green
    }

    init(
        parent: GMSceneNode?,
        children: [GMSceneNode],
        location: Point,
        transformation: float4x4,
        vertices: Vertices,
        color: float4
    ) {
        self.parent = parent
        self.children = children
        self.location = location
        self.transformation = transformation
        self.vertices = vertices
        self.color = color
    }

    func add(child: GMSceneNode) -> GMSceneNode {
        self
    }

    func delete(child: GMSceneNode) -> GMSceneNode {
        self
    }

    func update(elapsed: Double) -> GMSceneNode {
        self
    }
}
