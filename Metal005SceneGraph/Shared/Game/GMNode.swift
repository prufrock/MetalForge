//
// Created by David Kanenwisher on 10/5/21.
//

import MetalKit


class GMNode {
    // for the CPU
    var location: Point
    // for the GPU
    var vertices: Vertices
    var transformation: float4x4
    var state: NodeState
    var rate: Float

    init(
        location: Point,
        vertices: Vertices,
        transformation: float4x4 = matrix_identity_float4x4,
        initialState: NodeState = .forward,
        rate: Float = (1/3.8)
    ) {
        self.location = location
        self.vertices = vertices
        self.transformation = transformation
        self.state = initialState
        self.rate = rate
    }

    @discardableResult
    func move(elapsed: Double) -> GMNode {
        if (location.rawValue.x > 1) {
            self.state = .backward
        }

        if (location.rawValue.x < -1) {
            self.state = .forward
        }

        switch state {
        case .forward:
            translate(Float(elapsed) * rate, 0, 0)
        case .backward:
            translate(-1 * Float(elapsed) * rate, 0, 0)
        }
        return self
    }

    @discardableResult
    func translate(_ x: Float, _ y: Float, _ z: Float) -> GMNode {
        location = location.translate(x, y, z)
        transformation = float4x4.translate(
            x: location.rawValue.x + x,
            y: location.rawValue.y + y,
            z: location.rawValue.z + z
        )

        return self
    }

    enum NodeState {
        case forward
        case backward
    }
}