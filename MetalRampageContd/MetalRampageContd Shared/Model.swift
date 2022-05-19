//
// Created by David Kanenwisher on 5/16/22.
//

import Foundation

/**
 A shape to be rendered in 3D.
 I like calling it Model because it's a 3D model but it may need a name change...
 */
struct Model {
    let vertices: [Float3]
    let uv: [Float2] // texture coordinates
}

/**
 Well known Models get a label to make finding them easier.
 */
public enum ModelLabel: String {
    case unitSquare //centered on origin
}
