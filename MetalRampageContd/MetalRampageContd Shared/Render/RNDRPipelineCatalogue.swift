//
// Created by David Kanenwisher on 5/22/22.
//

import MetalKit

/**
 A place to find your favorite MTLRenderPipelineState objects for encoding commands.
 */
struct RNDRPipelineCatalogue {
    let texturePipeline: MTLRenderPipelineState
    let textureIndexedPipeline: MTLRenderPipelineState
    let textureIndexedSpriteSheetPipeline: MTLRenderPipelineState
    let vertexPipeline: MTLRenderPipelineState
    let effectPipeline: MTLRenderPipelineState

    init(device: MTLDevice) {

        guard let library = device.makeDefaultLibrary() else {
            fatalError("""
                       What in the what?! The library couldn't be loaded.
                       """)
        }

        vertexPipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_main")
            $0.fragmentFunction = library.makeFunction(name: "fragment_main")
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            $0.depthAttachmentPixelFormat = .depth32Float
        })

        texturePipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_with_texcoords")
            $0.fragmentFunction = library.makeFunction(name: "fragment_with_texture")
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            $0.depthAttachmentPixelFormat = .depth32Float
            $0.vertexDescriptor = MTLVertexDescriptor().apply {
                $0.attributes[0].format = MTLVertexFormat.float3
                $0.attributes[0].bufferIndex = 0
                $0.attributes[0].offset = 0
                $0.attributes[1].format = MTLVertexFormat.float2
                $0.attributes[1].bufferIndex = 1
                $0.attributes[1].offset = 0
                $0.layouts[0].stride = MemoryLayout<Float3>.stride
                $0.layouts[1].stride = MemoryLayout<Float2>.stride
            }
        })

        textureIndexedPipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_indexed")
            $0.fragmentFunction = library.makeFunction(name: "fragment_with_texture")
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            $0.depthAttachmentPixelFormat = .depth32Float
            $0.vertexDescriptor = MTLVertexDescriptor().apply {
                $0.attributes[0].format = MTLVertexFormat.float3
                $0.attributes[0].bufferIndex = 0
                $0.attributes[0].offset = 0
                $0.attributes[1].format = MTLVertexFormat.float2
                $0.attributes[1].bufferIndex = 1
                $0.attributes[1].offset = 0
                $0.layouts[0].stride = MemoryLayout<Float3>.stride
                $0.layouts[1].stride = MemoryLayout<Float2>.stride
            }
        })

        textureIndexedSpriteSheetPipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_indexed_sprite_sheet")
            $0.fragmentFunction = library.makeFunction(name: "fragment_with_texture")
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            $0.depthAttachmentPixelFormat = .depth32Float
            $0.vertexDescriptor = MTLVertexDescriptor().apply {
                $0.attributes[0].format = MTLVertexFormat.float3
                $0.attributes[0].bufferIndex = 0
                $0.attributes[0].offset = 0
                $0.attributes[1].format = MTLVertexFormat.float2
                $0.attributes[1].bufferIndex = 1
                $0.attributes[1].offset = 0
                $0.layouts[0].stride = MemoryLayout<Float3>.stride
                $0.layouts[1].stride = MemoryLayout<Float2>.stride
            }
        })

        effectPipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_main")
            $0.fragmentFunction = library.makeFunction(name: "fragment_effect")
            $0.depthAttachmentPixelFormat = .depth32Float
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            // Enable blending on the effects pipeline
            $0.colorAttachments[0].isBlendingEnabled = true
            $0.colorAttachments[0].rgbBlendOperation = .add
            $0.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            $0.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        })
    }
}
