//
// Created by David Kanenwisher on 5/16/22.
//

import Foundation

/**
 A shape to be rendered in 3D.
 I like calling it Model because it's a 3D model but it may need a name change...
 I also suspect once I have models loaded in from this will need to change. Possibly even for models defined in more than one plane.
 */
struct RNDRModel {
    let vertices: [Float3]
    let uv: [Float2]
    let index: [UInt16]
    let normals: [Float3]

    /**
     Uses the index to construct the complete list of vertices.
     - Returns: All of the vertices for the model.
     */
    func allVertices() -> [Float3] {
        index.map { i in
            vertices[Int(i)]
        }
    }

    /**
     Use the index to create the complete list of uv coordinates.
     - Returns: All of the uv coordinates for the model.
     */
    func allUv() -> [Float2] {
        index.map { i in
            uv[Int(i)]
        }
    }

    func normalLines() -> [Float3] {
        var normalLines: [Float3] = []
        let vertices: [Float3] = allVertices()
        let normals: [Float3] = normals
        for i in (0 ..< vertices.count) {
            normalLines.append(vertices[i])
            normalLines.append(GMRay3d(origin: vertices[i], direction: normals[i]).pointOnRay(t: 1.0))
        }

        return normalLines
    }
}

/**
 Well known Models get a label to make finding them easier.
 */
enum ModelLabel: String {
    case unitSquare //centered on origin
}
