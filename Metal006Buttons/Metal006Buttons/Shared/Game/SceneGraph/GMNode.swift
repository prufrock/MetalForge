//
// Created by David Kanenwisher on 11/29/21.
//

protocol GMNode {
    var element: RenderableNode { get }

    var children: [GMNode] { get }

    func add(child: GMNode) -> GMNode

    func delete(child: GMNode) -> GMNode

    //TODO remove everything that isn't related to managing the tree
    //TODO RenderableNode
    func update(transform: (GMNode) -> GMNode) -> GMNode

    func setChildren(_ children: [GMNode]) -> GMNode

    //TODO rename to traverse?
    func render(to: (RenderableNode) -> Void)

    //TODO RenderableNode
    func translate(_ transform: Float4x4) -> GMNode
}