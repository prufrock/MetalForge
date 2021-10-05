//
// Created by David Kanenwisher on 10/5/21.
//

import MetalKit

protocol World {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var nodes: [Node] { get }

    func click()

    func setCameraDimension(top: Float, bottom: Float)

    func update(elapsed: Double)
}

func GMCreateWorld() -> World {
    GameWorld(nodes: [], cameraDimensions: (Float(1.0), Float(1.0)))
}

class GameWorld: World {
    var cameraTop: Float
    var cameraBottom: Float
    var state: WorldState
    var rate: Float
    var nodes: [Node]

    init(nodes: [Node],
         state: WorldState = .playing,
         rate: Float = 0.005,
         cameraDimensions: (Float, Float)
    ) {
        self.state = state
        self.rate = rate
        self.nodes = nodes
        self.cameraTop = cameraDimensions.0
        self.cameraBottom = cameraDimensions.1
    }

    func setCameraDimension(top: Float, bottom: Float) {
        cameraTop = top
        cameraBottom = bottom
    }

    func click() {
        switch state {
        case .playing:
            state = .paused
            self.nodes.append(
                Node(
                    location: Point(
                        Float.random(in: -1...1),
                        Float.random(in: self.cameraBottom...self.cameraTop),
                        Float.random(in: 0...1)
                    ),
                    vertices: VerticeCollection().c[.cube]!
                )
            )
        case .paused:
            state = .playing
        }
    }

    func update(elapsed: Double) {
        switch state {
        case .playing:
            nodes.forEach { node in
                node.move(elapsed: elapsed)
            }
        case .paused:
            nodes.forEach { node in
                if (node !== nodes.last) {
                    node.move(elapsed: elapsed)
                }
            }
        }
    }

    enum WorldState {
        case playing
        case paused
    }
}

class Node {
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
    func move(elapsed: Double) -> Node {
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
    func translate(_ x: Float, _ y: Float, _ z: Float) -> Node {
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
