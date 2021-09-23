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
    let vertices: Vertices
    var previous: Double
    var world: World

    init(metalBits: MetalBits, vertices: Vertices, world: World) {
        self.metalBits = metalBits
        self.vertices = vertices
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

        let buffer = metalBits.device.makeBuffer(bytes: world.vertices.toFloat4(), length: vertices.memoryLength(), options: [])

        encoder.setRenderPipelineState(metalBits.pipelines[.simple]!)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBytes(&transform, length: MemoryLayout<float4x4>.stride, index: 1)

        var color = Colors().green
        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
        encoder.drawPrimitives(type: world.vertices.primitiveType, vertexStart: 0, vertexCount: world.vertices.count)
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
    var vertices: Vertices { get }

    func update(elapsed: Double)
}

class GameWorld: World {
    var vertices: Vertices
    var state: WorldState
    var rate: Float

    init(vertices: Vertices, state: WorldState = .forward, rate: Float = 0.005) {
        self.vertices = vertices
        self.state = state
        self.rate = rate
    }

    func update(elapsed: Double) {
        if (vertices.vertices[0].rawValue.x > 1) {
            self.state = .backward
        }

        if (vertices.vertices[0].rawValue.x < 0) {
            self.state = .forward
        }

        switch state {
        case .forward:
            vertices = Vertices([vertices.vertices[0].translate(rate, 0, 0)])
        case .backward:
            vertices = Vertices([vertices.vertices[0].translate(-1 * rate, 0, 0)])
        }

    }

    enum WorldState {
        case forward
        case backward
    }
}