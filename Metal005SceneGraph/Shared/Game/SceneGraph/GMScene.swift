//
// Created by David Kanenwisher on 10/24/21.
//

import Foundation

protocol GMScene {
    var nodes: [GMSceneNode] { get }

    func update(elapsed: Double) -> GMScene
}

protocol GMSceneNode {
    func add(child: GMSceneNode) -> GMSceneNode

    func delete(child: GMSceneNode) -> GMSceneNode

    func update(elapsed: Double) -> GMSceneNode
}

struct GMSceneImmutableScene: GMScene {
    let nodes: [GMSceneNode]

    func update(elapsed: Double) -> GMScene {
        self
    }
}

struct GMSceneImmutableNode: GMSceneNode {
    let parent: GMSceneNode?
    let children: [GMSceneNode]

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
