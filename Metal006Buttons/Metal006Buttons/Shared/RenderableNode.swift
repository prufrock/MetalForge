//
// Created by David Kanenwisher on 10/26/21.
//

protocol RenderableNode {
    var location: Point { get }
    var transformation: float4x4 { get }
    var vertices: Vertices { get }
    var color: float4 { get }
    var hidden: Bool { get }
}
