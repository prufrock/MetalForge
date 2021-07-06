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
        print(#function)

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

        // Make a buffer to hold the vertices
        let buffer = device.makeBuffer(bytes: vertices.toFloat4(), length: vertices.memoryLength(), options: [])

        // Pass data into the render encoder so that something is actually rendered to the screen.
        encoder.setRenderPipelineState(pipeline)

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