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
    GMImmutableGameWorld(
        nodes: [],
        state: .playing,
        rate: 0.005,
        cameraDimensions: (Float(1.0), Float(1.0))
    )
}

class GMImmutableGameWorld: GMWorld {
    let cameraTop: Float
    let cameraBottom: Float
    let state: WorldState
    let rate: Float
    let nodes: [GMNode]

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
        clone(cameraDimensions: (top, bottom))
    }

    @discardableResult
    func click() -> GMWorld {
        let newState: WorldState
        let newNodes: [GMNode]
        switch state {
        case .playing:
            newState = .paused
            newNodes = nodes +
                [GMCreateNode(
                    location: Point(
                        Float.random(in: -1...1),
                        Float.random(in: self.cameraBottom...self.cameraTop),
                        Float.random(in: 0...1)
                    ),
                    vertices: VerticeCollection().c[.cube]!,
                    initialState: .forward,
                    rate: Float(0.26),
                    color: Colors().green
                )]
        case .paused:
            newState = .playing
            newNodes = nodes
        }

        return clone(nodes: newNodes, state: newState)
    }

    @discardableResult
    func update(elapsed: Double) -> GMWorld {
        var newNodes: [GMNode]
        switch state {
        case .playing:
            newNodes = nodes.map { node in
                node.move(elapsed: elapsed).setColor(Colors().green)
            }
        case .paused:
            newNodes = updateAllButNewestNode(elapsed: elapsed, nodes: nodes)
        }

        if(newNodes.count >= 1) {
            newNodes = newNodes[0..<(nodes.endIndex-1)] + [newNodes.last!.setColor(Colors().red)]
        }

        return clone(nodes: newNodes)
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

    private func clone(
        nodes: [GMNode]? = nil,
        state: WorldState? = nil,
        rate: Float? = nil,
        cameraDimensions: (Float, Float)? = nil
    ) -> GMWorld {
        GMImmutableGameWorld(
            nodes: nodes ?? self.nodes,
            state: state ?? self.state,
            rate: rate ?? self.rate,
            cameraDimensions: cameraDimensions ?? (self.cameraTop, self.cameraBottom)
        )
    }
}

extension Collection {
    var lastIndex: Int { return self.count - 1 }
}

