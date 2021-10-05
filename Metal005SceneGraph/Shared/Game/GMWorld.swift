//
// Created by David Kanenwisher on 10/5/21.
//

import MetalKit

protocol GMWorld {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var nodes: [PGMNode] { get }

    func click()

    func setCameraDimension(top: Float, bottom: Float)

    func update(elapsed: Double)
}

func GMCreateWorld() -> GMWorld {
    GMGameWorld(
        nodes: [],
        state: .playing,
        rate: 0.005,
        cameraDimensions: (Float(1.0), Float(1.0))
    )
}

class GMGameWorld: GMWorld {
    var cameraTop: Float
    var cameraBottom: Float
    var state: WorldState
    var rate: Float
    var nodes: [PGMNode]

    init(nodes: [PGMNode],
         state: WorldState,
         rate: Float,
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
                GMSimpleNode(
                    location: Point(
                        Float.random(in: -1...1),
                        Float.random(in: self.cameraBottom...self.cameraTop),
                        Float.random(in: 0...1)
                    ),
                    vertices: VerticeCollection().c[.cube]!,
                    initialState: .forward,
                    rate: Float(0.26)
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
                node.setColor(Colors().green)
            }
        case .paused:
            updateAllButNewestNode(elapsed: elapsed)
        }
        nodes.last?.setColor(Colors().red)
    }

    func updateAllButNewestNode(elapsed: Double) {
        for i in 0..<nodes.lastIndex {
            nodes[i].move(elapsed: elapsed).setColor(Colors().green)
        }
    }

    enum WorldState {
        case playing
        case paused
    }
}

extension Collection {
    var lastIndex: Int { return self.count - 1 }
}

