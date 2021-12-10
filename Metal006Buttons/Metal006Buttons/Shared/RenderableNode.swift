//
// Created by David Kanenwisher on 10/26/21.
//

protocol RenderableNode {
    var location: Point { get }
    var transformation: Float4x4 { get }
    var vertices: Vertices { get }
    var color: Float4 { get }
    var hidden: Bool { get }

    func setColor(_ color: Float4) -> RenderableNode

    //It seems like 'move' is at a lower abstraction then 'translate'.
    //TODO should move go somewhere else?
    func move(elapsed: Double) -> GMNode

    //Is translate part of rendering?
    //TODO should translate go somewhere else?
    func translate(_ transform: Float4x4) -> GMNode
}
