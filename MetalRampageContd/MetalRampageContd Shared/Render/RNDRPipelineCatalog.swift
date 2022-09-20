//
// Created by David Kanenwisher on 5/22/22.
//

import Metal

/**
 A place to find your favorite MTLRenderPipelineState objects for encoding commands.
 */
struct RNDRPipelineCatalog {
    let effectPipeline: MTLRenderPipelineState
    let spriteSheetPipeline: MTLRenderPipelineState
    let texturePipeline: MTLRenderPipelineState
    let textureIndexedPipeline: MTLRenderPipelineState
    let textureIndexedSpriteSheetPipeline: MTLRenderPipelineState
    let vertexPipeline: MTLRenderPipelineState
    let wireFramePipeline: MTLRenderPipelineState
    let textureIndexedSpriteSheetLightingPipeline: MTLRenderPipelineState

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

        wireFramePipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_indexed")
            $0.fragmentFunction = library.makeFunction(name: "fragment_main")
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

        textureIndexedSpriteSheetLightingPipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_indexed_lighting")
            $0.fragmentFunction = library.makeFunction(name: "fragment_simple_light")
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            $0.depthAttachmentPixelFormat = .depth32Float
            $0.vertexDescriptor = MTLVertexDescriptor().apply {
                // .position
                $0.attributes[VertexAttribute.position.rawValue].format = MTLVertexFormat.float3
                $0.attributes[VertexAttribute.position.rawValue].bufferIndex = VertexAttribute.position.rawValue
                $0.attributes[VertexAttribute.position.rawValue].offset = 0
                $0.layouts[VertexAttribute.position.rawValue].stride = MemoryLayout<Float3>.stride
                // .uv
                $0.attributes[VertexAttribute.uvcoord.rawValue].format = MTLVertexFormat.float2
                $0.attributes[VertexAttribute.uvcoord.rawValue].bufferIndex = VertexAttribute.uvcoord.rawValue
                $0.attributes[VertexAttribute.uvcoord.rawValue].offset = 0
                $0.layouts[VertexAttribute.uvcoord.rawValue].stride = MemoryLayout<Float2>.stride
                // .normal
                $0.attributes[VertexAttribute.normal.rawValue].format = MTLVertexFormat.float3
                $0.attributes[VertexAttribute.normal.rawValue].bufferIndex = VertexAttribute.normal.rawValue
                $0.attributes[VertexAttribute.normal.rawValue].offset = 0
                $0.layouts[VertexAttribute.normal.rawValue].stride = MemoryLayout<Float3>.stride
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

        spriteSheetPipeline = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.vertexFunction = library.makeFunction(name: "vertex_only_transform")
            $0.fragmentFunction = library.makeFunction(name: "fragment_sprite_sheet")
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
    }
}
