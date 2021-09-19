//
//  Vertices.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import MetalKit

struct Vertices {
    let vertices: [Point]
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

    func memoryLength() -> Int {
        MemoryLayout<float4>.stride * vertices.count
    }

    func toFloat4() -> [float4] {
        vertices.map { p in float4(p.rawValue.x, p.rawValue.y, p.rawValue.z, 1)}
    }
}

