//
// Created by David Kanenwisher on 7/8/21.
//

import Foundation
import MetalKit

class Drawer: NSObject {
    let view: MTKView
    let device: MTLDevice
    let pipeline: MTLRenderPipelineState
    let vertices: Vertices
    var counter: Double = 0

    init(view: MTKView, device: MTLDevice, pipeline: MTLRenderPipelineState, vertices: Vertices) {
        self.view = view
        self.device = device
        self.pipeline = pipeline
        self.vertices = vertices

        super.init()

        view.delegate = self

        view.device = device

        view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

        mtkView(view, drawableSizeWillChange: view.bounds.size)
    }

    class Builder {
        var view: MTKView? = nil
        var device: MTLDevice? = nil
        var pipeline: MTLRenderPipelineState? = nil
        var vertices: Vertices? = nil

        func build() -> Drawer {
            guard let view = view else {
                fatalError("""
                           Shoot, you forgot to give me a MTKView. I can't build your view now! Crashing...KAPOW!
                           """)
            }

            guard let device = device else {
                fatalError("""
                           Shoot, you forgot to give me a MTLDevice. I can't build your view now! Crashing...KAPOW!
                           """)
            }

            guard let pipeline = pipeline else {
                fatalError("""
                           Shoot, you forgot to give me a MTLPipelineState. I can't build your view now! Crashing...KAPOW!
                           """)
            }

            guard let vertices = vertices else {
                fatalError("""
                           Shoot, you forgot to give me some vertices. I can't build your view now! Crashing...KAPOW!
                           """)
            }

            return Drawer(
                    view: view,
                    device: device,
                    pipeline: pipeline,
                    vertices: vertices
            )
        }
    }
}

extension Drawer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
    }

    func draw(in view: MTKView) {
        guard let commandQueue = device.makeCommandQueue() else {
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

        let buffer = device.makeBuffer(bytes: vertices.toFloat4(), length: vertices.memoryLength(), options: [])

        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBytes(&transform, length: MemoryLayout<float4x4>.stride, index: 1)

        var color = float4(1.0, 1.0, 1.0, 1.0)
        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
        encoder.drawPrimitives(type: vertices.primitiveType, vertexStart: 0, vertexCount: vertices.count)
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
