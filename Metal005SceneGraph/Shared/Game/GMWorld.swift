//
// Created by David Kanenwisher on 10/5/21.
//

import MetalKit

protocol GMWorld {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var nodes: [GMNode] { get }

    func click()

    func setCameraDimension(top: Float, bottom: Float)

    func update(elapsed: Double)
}

func GMCreateWorld() -> GMWorld {
    GMGameWorld(nodes: [], cameraDimensions: (Float(1.0), Float(1.0)))
}

class GMGameWorld: GMWorld {
    var cameraTop: Float
    var cameraBottom: Float
    var state: WorldState
    var rate: Float
    var nodes: [GMNode]

    init(nodes: [GMNode],
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
                GMNode(
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


