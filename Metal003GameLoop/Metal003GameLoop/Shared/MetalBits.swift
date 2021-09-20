//
//  MetalBits.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import MetalKit

struct MetalBits {
    let view: MTKView
    let device: MTLDevice
    let pipelines: [PipelineName: MTLRenderPipelineState]
    let commandQueue: MTLCommandQueue

    static func create(view: MTKView) -> MetalBits {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("""
                       I looked in the computer and didn't find a device...sorry =/
                       """)
        }

        view.device = device

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("""
                       What?! No comand queue. Come on!
                       """)
        }

        guard let library = device.makeDefaultLibrary() else {
            fatalError("""
                       What in the what?! The library couldn't be loaded.
                       """)
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let defaultPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)


        return MetalBits(
            view: view,
            device: MTLCreateSystemDefaultDevice()!,
            pipelines: [.simple: defaultPipelineState],
            commandQueue: commandQueue
        )
    }

    enum PipelineName {
        case simple
    }
}
