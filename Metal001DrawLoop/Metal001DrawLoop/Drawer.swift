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

        encoder.endEncoding()
    }
}