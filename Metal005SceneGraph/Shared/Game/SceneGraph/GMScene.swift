//
// Created by David Kanenwisher on 10/24/21.
//

import Foundation

protocol GMSceneNode: RenderableNode {
    func add(child: GMSceneNode) -> GMSceneNode

    func delete(child: GMSceneNode) -> GMSceneNode

    func update(elapsed: Double) -> GMSceneNode
}

func GMCreateScene() -> RenderableCollection {
   GMSceneImmutableScene(
       nodes: [],
       cameraDimensions: (1.0, 1.0)
   )
}

struct GMSceneImmutableScene: RenderableCollection {
    let cameraTop: Float
    let cameraBottom: Float
    let nodes: [GMSceneNode]

    init(nodes: [GMSceneNode],
         cameraDimensions: (Float, Float)
    ) {
        self.nodes = nodes
        self.cameraTop = cameraDimensions.0
        self.cameraBottom = cameraDimensions.1
    }

    func click() -> RenderableCollection {
        self
    }

    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection {
        self
    }

    func render(to: (RenderableNode) -> Void) {
        nodes.forEach { node in to(node) }
    }

    func update(elapsed: Double) -> RenderableCollection {
        self
    }

    private func clone(
        nodes: [GMSceneNode]? = nil,
        cameraDimensions: (Float, Float)? = nil
    ) -> RenderableCollection {
        GMSceneImmutableScene(
            nodes: nodes ?? self.nodes,
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
