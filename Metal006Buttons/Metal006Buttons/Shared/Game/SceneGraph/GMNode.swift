//
// Created by David Kanenwisher on 11/29/21.
//

protocol GMNode: RenderableNode {
    var children: [GMNode] { get }

    func add(child: GMNode) -> GMNode

    func delete(child: GMNode) -> GMNode

    func update(transform: (GMNode) -> GMNode) -> GMNode

    func setColor(_ color: float4) -> GMNode

    func setChildren(_ children: [GMNode]) -> GMNode

    func move(elapsed: Double) -> GMNode

    func render(to: (RenderableNode) -> Void)

    func translate(_ transform: float4x4) -> GMNode
}