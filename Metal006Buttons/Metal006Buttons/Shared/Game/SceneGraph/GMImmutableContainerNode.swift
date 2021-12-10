//
// Created by David Kanenwisher on 12/10/21.
//

import Foundation

struct GMImmutableContainerNode<T>: GMNode {
    let children: [GMNode]

    let location: Point

    let transformation: Float4x4

    let vertices: Vertices

    let color: Float4

    let hidden: Bool

    let item: T

    func add(child: GMNode) -> GMNode {
        clone(
            children: children + [child]
        )
    }

    func delete(child: GMNode) -> GMNode {
        self
    }

    func update(transform: (GMNode) -> GMNode) -> GMNode {
        self
    }

    func setColor(_ color: Float4) -> GMNode {
        self
    }

    func setChildren(_ children: [GMNode]) -> GMNode {
        self
    }

    func move(elapsed: Double) -> GMNode {
        self
    }

    func render(to: (RenderableNode) -> Void) {

    }

    func translate(_ transform: Float4x4) -> GMNode {
        self
    }

    private func clone(
        children: [GMNode]? = nil,
        location: Point? = nil,
        transformation: Float4x4? = nil,
        vertices: Vertices? = nil,
        color: Float4? = nil,
        hidden: Bool? = nil,
        item: T? = nil
    ) -> GMImmutableContainerNode {
        GMImmutableContainerNode(
            children: children ?? self.children,
            location: location ?? self.location,
            transformation: transformation ?? self.transformation,
            vertices: vertices ?? self.vertices,
            color: color ?? self.color,
            hidden: hidden ?? self.hidden,
            item: item ?? self.item
        )
    }
}
