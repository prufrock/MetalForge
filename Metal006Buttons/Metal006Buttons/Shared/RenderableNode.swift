//
// Created by David Kanenwisher on 10/26/21.
//

protocol RenderableNode {
    var location: Point { get }
    var transformation: Float4x4 { get }
    var vertices: Vertices { get }
    var color: Float4 { get }
    var hidden: Bool { get }

    func setColor(_ color: Float4) -> GMNode
}
