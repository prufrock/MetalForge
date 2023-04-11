//
//  Renderer.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation
import MetalKit

struct Renderer {
    private let view: MTKView
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let depthStencilState: MTLDepthStencilState
    private let vertexPipeline: MTLRenderPipelineState
    private(set) var aspect: Float = 1.0

    init(_ view: MTKView, width: Int, height: Int) {
        self.view = view

        guard let newDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("""
                       I looked in the computer and didn't find a device...sorry =/
                       """)
        }

        view.device = newDevice
        view.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.depthStencilPixelFormat = .depth32Float

        device = newDevice

        guard let newCommandQueue = device.makeCommandQueue() else {
            fatalError("""
                       What?! No comand queue. Come on!
                       """)
        }

        commandQueue = newCommandQueue

        guard let depthStencilState = device.makeDepthStencilState(descriptor: MTLDepthStencilDescriptor().apply {
            $0.depthCompareFunction = .less
            $0.isDepthWriteEnabled = true
        }) else {
            fatalError("""
                       Agh?! The depth stencil state didn't work.
                       """)
        }

        self.depthStencilState = depthStencilState

        guard let library = device.makeDefaultLibrary() else {
            fatalError("""
                       What in the what?! The library couldn't be loaded.
                       """)
        }

        self.vertexPipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_main")
            $0.fragmentFunction = library.makeFunction(name: "fragment_main")
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            $0.depthAttachmentPixelFormat = .depth32Float
            $0.vertexDescriptor = MTLVertexDescriptor().apply {
                // .position
                $0.attributes[0].format = MTLVertexFormat.float3
                $0.attributes[0].bufferIndex = 0
                $0.attributes[0].offset = 0
                $0.layouts[0].stride = MemoryLayout<Float3>.stride
            }
        })
    }

    mutating func updateAspect(width: Float, height: Float) {
        aspect = (width / height)
    }

    func render(_ game: Game) {

        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
            fatalError("""
                       Ugh, no command buffer. What the heck!
                       """)
        }

        guard let descriptor = view.currentRenderPassDescriptor, let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("""
                       Dang it, couldn't create a command encoder.
                       """)
        }

        game.world.actors.forEach { actor in
            let model: Model
            switch actor.model {
            case .dot:
                model = Dot()
            case .square:
                model = Square()
            case .wfSquare:
                model = WireframeSquare()
            }

            let viewToClip = Float4x4.identity()
            let clipToNdc = Float4x4.identity()
            let ndcToScreen = Float4x4.identity()


            var finalTransform: Float4x4
            if actor is ClickLocation || actor is Button {
                finalTransform = ndcToScreen
                * clipToNdc
                * viewToClip
                * game.world.hudCamera.worldToView(fov: .pi/2, aspect: aspect, nearPlane: 0.1, farPlane: 20.0)
                * actor.uprightToWorld
                * actor.modelToUpright
            } else {
                finalTransform = ndcToScreen
                * clipToNdc
                * viewToClip
                * game.world.camera!.worldToView(fov: .pi/2, aspect: aspect, nearPlane: 0.1, farPlane: 20.0)
                * actor.uprightToWorld
                * actor.modelToUpright
            }

            let buffer = device.makeBuffer(bytes: model.v, length: MemoryLayout<Float3>.stride * model.v.count, options: [])

            encoder.setRenderPipelineState(vertexPipeline)
            encoder.setDepthStencilState(depthStencilState)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)

            var fragmentColor = actor.color

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: model.primitiveType, vertexStart: 0, vertexCount: model.v.count)


        }
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
