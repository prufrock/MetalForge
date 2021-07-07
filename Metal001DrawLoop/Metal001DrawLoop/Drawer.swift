//
// Created by David Kanenwisher on 7/5/21.
//

import Foundation
import MetalKit

class Drawer: NSObject {
    let view: MTKView
    let device: MTLDevice
    let pipeline: MTLRenderPipelineState
    let vertices: Vertices

    init(view: MTKView, device: MTLDevice, pipeline: MTLRenderPipelineState, vertices: Vertices) {
        self.view = view
        self.device = device
        self.pipeline = pipeline
        self.vertices = vertices

        // Initialize NSObject so it can do what it needs to do.
        super.init()

        // Set the Drawer to the view delegate. Make sure the Drawer is fully initialized before doing this since
        // the object has now escaped. The fact that the objects escapes at this point makes me wonder if this isn't
        // the best place to do this. It seems a bit sneaky if you're trying to understand the threading model if
        // the an object escapes during the initializer.
        view.delegate = self

        // The view needs to know the device that it's going to be working with.
        view.device = device

        // Set the clear color(background color of the rendered image) to black because black is cool.
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

        // Call mtkView to set the initial size of the viewport. More happens here later.
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
                       What?! No command queue. Come on!
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

        // Needs to be assigned to a variable so the pointer can be passed to the shader via setVertexBytes.
        // This is the base of the transformation matrix used to do any simple transformations to the vertices by the
        // shader. This is really about the only bit I have in here right now that makes cool GPU stuff happen.
        var transform = matrix_identity_float4x4

        // Make a buffer to hold the vertices
        let buffer = device.makeBuffer(bytes: vertices.toFloat4(), length: vertices.memoryLength(), options: [])

        // Pass data into the render encoder so that something is actually rendered to the screen.

        // It needs a pipeline state object
        encoder.setRenderPipelineState(pipeline)

        // Set the vertex buffers which are the buffers used to determine the position of objects in space.
        // The vertex buffer has to start with the buffer at 0. I assume this lines up with the buffers
        // referenced in the shaders. I thought I tried that out at some point but now I'm not 100% sure.
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        // Additional data passed to the vertex buffer in this case the matrix used to perform a transformation on the
        // vertices.
        encoder.setVertexBytes(&transform, length: MemoryLayout<float4x4>.stride, index: 1)

        // The fragment buffer determines the colors of everything that is rendered. I need to better understand how
        // this relates to the way pixels are ultimately colored on the screen. I haven't spent much time here yet.
        // A universal color for every vertex passed in. I'll likely change this later so I can have different color
        // vertices.
        var color = float4(1.0, 1.0, 1.0, 1.0)
        // Pass the vertices to the fragment buffer.
        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        // Pass the color information to the fragment buffer
        encoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)

        // Draw the vertices as points on the screen.
        encoder.drawPrimitives(type: vertices.primitiveType, vertexStart: 0, vertexCount: vertices.count)

        encoder.endEncoding()

        // Need to get the drawable out of the view so the command buffer can commit to it.
        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        // The command buffer won't do anything with it's output unless it presents to the MTLView's drawable and is
        // committed.
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}