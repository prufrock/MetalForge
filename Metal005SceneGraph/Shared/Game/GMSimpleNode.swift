//
// Created by David Kanenwisher on 10/5/21.
//

import MetalKit

protocol GMNode {
    var location: Point { get }
    var transformation: float4x4 { get }
    var vertices: Vertices { get }
    var color: float4 { get }

    func move(elapsed: Double) -> GMNode

    func setColor(_ color: float4) -> GMNode
}

enum GMNodeState {
    case forward
    case backward
}

func GMCreateNode(location: Point,
                  vertices: Vertices,
                  initialState: GMNodeState,
                  rate: Float,
                  color: float4
    ) -> GMNode {
    return GMSimpleNode(
        location: location,
        vertices: vertices,
        initialState: initialState,
        rate: rate,
        color: color
    )
}

struct GMImmutableNode: GMNode {
    // for the CPU
    let location: Point
    // for the GPU
    let vertices: Vertices

    let transformation: float4x4
    let rate: Float
    let color: float4

    let state: GMNodeState

    init(
        location: Point,
        vertices: Vertices,
        initialState: GMNodeState,
        rate: Float,
        color: float4 = Colors().green
    ) {
        self.location = location
        self.vertices = vertices
        self.state = initialState
        self.rate = rate
        self.color = color
        self.transformation = matrix_identity_float4x4
    }

    init(
        location: Point,
        vertices: Vertices,
        initialState: GMNodeState,
        rate: Float,
        color: float4 = Colors().green,
        transformation: float4x4
    ) {
        self.location = location
        self.vertices = vertices
        self.state = initialState
        self.rate = rate
        self.color = color
        self.transformation = transformation
    }

    func move(elapsed: Double) -> GMNode {

        let newState: GMNodeState
        if (location.rawValue.x > 1) {
            newState = .backward
        } else if (location.rawValue.x < -1) {
            newState = .forward
        } else {
            newState = state
        }

        let newLocation: Point
        let newTransformation: float4x4
        switch state {
        case .forward:
            (newLocation, newTransformation) = translate(Float(elapsed) * rate, 0, 0)
        case .backward:
            (newLocation, newTransformation) = translate(-1 * Float(elapsed) * rate, 0, 0)
        }

        return clone(location: newLocation, state: newState, transformation: newTransformation)
    }

    func setColor(_ color: float4) -> GMNode {
        clone(color: color)
    }

    private func translate(_ x: Float, _ y: Float, _ z: Float) -> (Point, float4x4) {
        let newLocation = location.translate(x, y, z)
        let newTransformation = float4x4.translate(
            x: location.rawValue.x + x,
            y: location.rawValue.y + y,
            z: location.rawValue.z + z
        )

        return (newLocation, newTransformation)
    }

    private func clone(
        location: Point? = nil,
        vertices: Vertices? = nil,
        state: GMNodeState? = nil,
        rate: Float? = nil,
        color: float4? = nil,
        transformation: float4x4? = nil
    ) -> GMNode {
        GMImmutableNode(
            location: location ?? self.location,
            vertices: vertices ?? self.vertices,
            initialState: state ?? self.state,
            rate: rate ?? self.rate,
            transformation: transformation ?? self.transformation
        )
    }
}


class GMSimpleNode: GMNode {
    // for the CPU
    var location: Point
    // for the GPU
    var vertices: Vertices
    var transformation: float4x4 = matrix_identity_float4x4
    var state: GMNodeState
    var rate: Float
    var color: float4

    init(
        location: Point,
        vertices: Vertices,
        initialState: GMNodeState,
        rate: Float,
        color: float4 = Colors().green
    ) {
        self.location = location
        self.vertices = vertices
        self.state = initialState
        self.rate = rate
        self.color = color
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

    @discardableResult
    func setColor(_ color: float4) -> GMNode {
        self.color = color

        return self
    }
}
