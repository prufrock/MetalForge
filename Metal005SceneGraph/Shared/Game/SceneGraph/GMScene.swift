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
   GMSceneImmutableScene(nodes: [])
}

struct GMSceneImmutableScene: RenderableCollection {
    let nodes: [GMSceneNode]

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
