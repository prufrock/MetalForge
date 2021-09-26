//
//  Drawer.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import Foundation
import MetalKit

class Drawer: NSObject {
    let metalBits: MetalBits
    var previous: Double
    var world: World

    init(metalBits: MetalBits, world: World) {
        self.metalBits = metalBits
        self.previous = CACurrentMediaTime()
        self.world = world

        super.init()

        self.metalBits.view.delegate = self

        self.metalBits.view.clearColor = MTLClearColor(Colors().black)

        mtkView(
            self.metalBits.view,
            drawableSizeWillChange: self.metalBits.view.bounds.size
        )
    }

    private func render(in view: MTKView) {
        guard let commandQueue = metalBits.device.makeCommandQueue() else {
            fatalError("""
                       What?! No comand queue. Come on!
                       """)
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("""
                       Ugh, no command buffer. What the heck!
                       """)
        }

        guard let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("""
                       Dang it, couldn't create a command encoder.
                       """)
        }

        var transform = matrix_identity_float4x4
                // projection
                * float4x4.perspectiveProjection(nearPlane: 0.2, farPlane: 1.0)
                // model
                //* float4x4.translate(x: 0.3, y: 0.3, z: 0.0)
        		* world.node.transformation

        let buffer = metalBits.device.makeBuffer(bytes: world.node.vertices.toFloat4(), length: world.node.vertices.memoryLength(), options: [])

        encoder.setRenderPipelineState(metalBits.pipelines[.simple]!)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBytes(&transform, length: MemoryLayout<float4x4>.stride, index: 1)

        var color = Colors().green
        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
        encoder.drawPrimitives(type: world.node.vertices.primitiveType, vertexStart: 0, vertexCount: world.node.vertices.count)
        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension Drawer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
    }

    func draw(in view: MTKView) {
        let current = CACurrentMediaTime()
        let delta = current - previous
        previous = current

        world.update(elapsed: delta)

        render(in: view)
    }
}

protocol World {
    var node: GameWorld.Node { get }

    func update(elapsed: Double)
}

class GameWorld: World {
    var state: WorldState
    var rate: Float
    var node: Node

    init(node: Node,
        state: WorldState = .forward,
        rate: Float = 0.005
    ) {
        self.node = node
        self.state = state
        self.rate = rate
    }

    func update(elapsed: Double) {
        if (node.location.rawValue.x > 1) {
            self.state = .backward
        }

        if (node.location.rawValue.x < 0) {
            self.state = .forward
        }

        switch state {
        case .forward:
            node.vertices = Vertices([node.vertices.vertices[0].translate(rate, 0, 0)])
            node.translate(rate, 0, 0)
        case .backward:
            node.vertices = Vertices([node.vertices.vertices[0].translate(-1 * rate, 0, 0)])
            node.translate(-1 * rate, 0, 0)
        }

    }

    enum WorldState {
        case forward
        case backward
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
            rate: Float = 0.005
        ) {
            self.location = location
            self.vertices = vertices
            self.transformation = transformation
            self.state = initialState
            self.rate = rate
        }

        @discardableResult
        func move() -> Node {
            if (vertices.vertices[0].rawValue.x > 1) {
                self.state = .backward
            }

            if (vertices.vertices[0].rawValue.x < 0) {
                self.state = .forward
            }

            switch state {
            case .forward:
                vertices = Vertices([vertices.vertices[0].translate(rate, 0, 0)])
                translate(rate, 0, 0)
            case .backward:
                vertices = Vertices([vertices.vertices[0].translate(-1 * rate, 0, 0)])
                translate(-1 * rate, 0, 0)
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
}
