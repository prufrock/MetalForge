//
// Created by David Kanenwisher on 11/29/21.
//

protocol GMNode {
    var element: RenderableNode { get }

    var children: [GMNode] { get }

    func add(child: GMNode) -> GMNode

    func delete(child: GMNode) -> GMNode

    //TODO this should update by finding the old node and replace
    // it with the new node. This update is a different sort of update.
    // It has a knowledge of traversing the whole tree in order to change all
    // nodes in the same way. This may be useful but maybe should be updateAll?
    // Plus it assumes that all nodes have the same element. I might be able to
    // get the same effect with traverse.
    func update(transform: (GMNode) -> GMNode) -> GMNode

    func setChildren(_ children: [GMNode]) -> GMNode

    //TODO rename to traverse?
    func render(to: (RenderableNode) -> Void)
}