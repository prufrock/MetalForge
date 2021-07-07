//
// Created by David Kanenwisher on 7/6/21.
//

import MetalKit

// I'm going to start by making this a struct and see how far I get.
// So far this seems like a pretty thin wrapper. I'm hoping it provides an decent abstraction to hang
// some helpful functions on. It might be premature to create this class. Sometimes it's nice to have
// a place where I can ideas on.
struct Vertices {
    let vertices: [Point]

    // I want to be able to switch between points and lines(eventually triangles) so I added a primitive type. It feels
    // a little weird to have this here. At the same time it doesn't go anywhere else yet.
    let primitiveType: MTLPrimitiveType

    var count: Int {
        vertices.count
    }

    init(_ vertices: [Point], primitiveType: MTLPrimitiveType = .point) {
        self.vertices = vertices
        self.primitiveType = primitiveType
    }

    init(_ vertices: Point..., primitiveType: MTLPrimitiveType = .point) {
        self.vertices = vertices
        self.primitiveType = primitiveType
    }

    // Make Vertices responsible for figuring out the length of the vertices being passed. I think I could make it
    // possible to pass Vertices into the shader but this seems easier to understand for now.
    func memoryLength() -> Int {
        MemoryLayout<float4>.stride * vertices.count
    }

    // Convert this to a float4. I can't remember whether the w should be 0 or 1 so setting it to 1 for now.
    func toFloat4() -> [float4] {
        vertices.map { p in float4(p.rawValue.x, p.rawValue.y, p.rawValue.z, 1) }
    }
}
