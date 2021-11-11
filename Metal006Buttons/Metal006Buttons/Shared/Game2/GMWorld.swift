//
// Created by David Kanenwisher on 10/5/21.
//

import MetalKit

protocol GMWorld {
    func click() -> GMWorld

    func setCameraDimension(top: Float, bottom: Float) -> GMWorld

    func update(elapsed: Double) -> GMWorld

    func render(to: (RenderableNode) -> Void)
}

func GMCreateWorld() -> RenderableCollection {
    GMImmutableGameWorld(
        nodes: [],
        state: .playing,
        rate: 0.005,
        cameraDimensions: (Float(1.0), Float(1.0))
    )
}

class GMImmutableGameWorld: RenderableCollection {
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

    func cameraSpace(withAspect aspect: Float) -> float4x4 {
        float4x4.perspectiveProjection(nearPlane: 0.2, farPlane: 1.0) * float4x4.scaleY(aspect)
    }

    @discardableResult
    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection {
        clone(cameraDimensions: (top, bottom))
    }

    @discardableResult
    func click() -> RenderableCollection {
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
    func update(elapsed: Double) -> RenderableCollection {
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
    ) -> RenderableCollection {
        GMImmutableGameWorld(
            nodes: nodes ?? self.nodes,
            state: state ?? self.state,
            rate: rate ?? self.rate,
            cameraDimensions: cameraDimensions ?? (self.cameraTop, self.cameraBottom)
        )
    }

    func render(to: (RenderableNode) -> Void) {
        self.nodes.forEach(to)
    }
}

extension Collection {
    var lastIndex: Int { return self.count - 1 }
}

