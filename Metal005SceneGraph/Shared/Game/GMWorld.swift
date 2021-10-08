//
// Created by David Kanenwisher on 10/5/21.
//

import MetalKit

protocol GMWorld {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var nodes: [GMNode] { get }

    func click() -> GMWorld

    func setCameraDimension(top: Float, bottom: Float) -> GMWorld

    func update(elapsed: Double) -> GMWorld
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
    var nodes: [GMNode]

    init(nodes: [GMNode],
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

    @discardableResult
    func setCameraDimension(top: Float, bottom: Float) -> GMWorld {
        cameraTop = top
        cameraBottom = bottom

        return self
    }

    @discardableResult
    func click() -> GMWorld {
        switch state {
        case .playing:
            state = .paused
            self.nodes.append(
                GMCreateNode(
                    location: Point(
                        Float.random(in: -1...1),
                        Float.random(in: self.cameraBottom...self.cameraTop),
                        Float.random(in: 0...1)
                    ),
                    vertices: VerticeCollection().c[.cube]!,
                    initialState: .forward,
                    rate: Float(0.26),
                    color: Colors().green
                )
            )
        case .paused:
            state = .playing
        }

        return self
    }

    @discardableResult
    func update(elapsed: Double) -> GMWorld {
        switch state {
        case .playing:
            nodes = nodes.map { node in
                node.move(elapsed: elapsed).setColor(Colors().green)
            }
        case .paused:
            nodes = updateAllButNewestNode(elapsed: elapsed, nodes: nodes)
        }
        nodes.last?.setColor(Colors().red)

        return self
    }

    private func updateAllButNewestNode(
        elapsed: Double,
        nodes oldNodes: [GMNode],
        newNodes: [GMNode] = []
    ) -> [GMNode] {
        if ((newNodes.lastIndex + 1) == oldNodes.lastIndex) {
            return newNodes + [oldNodes[oldNodes.lastIndex]]
        } else {
            return updateAllButNewestNode(elapsed: elapsed, nodes: oldNodes, newNodes: newNodes + [oldNodes[newNodes.count].move(elapsed: elapsed).setColor(Colors().green)])
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

