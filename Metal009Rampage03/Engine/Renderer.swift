//
// Created by David Kanenwisher on 12/13/21.
//

import Foundation
import MetalKit

public class Renderer: NSObject {
    let view: MTKView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let texturePipeline: MTLRenderPipelineState
    let vertexPipeline: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    public var aspect: Float = 1.0

    public init(_ view: MTKView, width: Int, height: Int) {
        self.view = view

        guard let newDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("""
                       I looked in the computer and didn't find a device...sorry =/
                       """)
        }

        view.device = newDevice
        view.clearColor = MTLClearColor(.black)
        view.depthStencilPixelFormat = .depth32Float

        device = newDevice

        guard let newCommandQueue = device.makeCommandQueue() else {
            fatalError("""
                       What?! No comand queue. Come on!
                       """)
        }

        commandQueue = newCommandQueue

        guard let library = device.makeDefaultLibrary() else {
            fatalError("""
                       What in the what?! The library couldn't be loaded.
                       """)
        }

        guard let depthStencilState = device.makeDepthStencilState(descriptor: MTLDepthStencilDescriptor().apply {
            $0.depthCompareFunction = .less
            $0.isDepthWriteEnabled = true
        }) else {
            fatalError("""
                       Agh?! The depth stencil state didn't work.
                       """)
        }

        self.depthStencilState = depthStencilState

        let vertexPipelineState = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.tessellationOutputWindingOrder = .clockwise
            $0.vertexFunction = library.makeFunction(name: "vertex_main")
            $0.fragmentFunction = library.makeFunction(name: "fragment_main")
            $0.colorAttachments[0].pixelFormat = .bgra8Unorm
            $0.depthAttachmentPixelFormat = .depth32Float
        })

        let texturePipelineState = try! device.makeRenderPipelineState(descriptor: MTLRenderPipelineDescriptor().apply {
            $0.tessellationOutputWindingOrder = .clockwise
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

        texturePipeline = texturePipelineState
        vertexPipeline = vertexPipelineState

        super.init()
    }

    public func render(_ world: World) {

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

        let worldTransform = Float4x4.identity()
            * Float4x4(scaleY: -1)

        let cameraTransform = Float4x4.identity()
            * Float4x4(translateX: -0.7, y: 0.9, z: 0)
            * Float4x4(scaleX: 0.03, y: 0.03, z: 1.0)
            * Float4x4(scaleY: aspect)

        drawGameworld(world: world, encoder: encoder)

        drawMap(world: world, encoder: encoder, cameraTransform: cameraTransform, worldTransform: worldTransform)

        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func drawGameworld(world: World, encoder: MTLRenderCommandEncoder) {
        var renderables: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType)] = []

//        renderables += LineCube(Float4x4(scaleX: 0.1, y: 0.1, z: 0.1))
//        renderables += LineCube(
//            Float4x4.identity()
//                * Float4x4(translateX: 1.0, y: 0.0, z: 0.0)
//                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
//        )
//        renderables += LineCube(
//            Float4x4.identity()
//                * Float4x4(translateX: -1.0, y: 0.0, z: 0.0)
//                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
//        )
//        renderables += LineCube(
//            Float4x4.identity()
//                * Float4x4(translateX: 0.0, y: 1.0, z: 0.0)
//                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
//        )
//
//        renderables += LineCube(
//            Float4x4.identity()
//                * Float4x4(translateX: 0.0, y: -1.0, z: 0.0)
//                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
//        )
//
//        renderables += LineCube(
//            Float4x4.identity()
//                * Float4x4(translateX: 0.0, y: 0.0, z: 1.0)
//                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
//        )
//
//        renderables += LineCube(
//            Float4x4.identity()
//                * Float4x4(translateX: 0.0, y: 0.0, z: -1.0)
//                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
//        )


        renderables += (TileImage(map: world.map).tiles)

        let cameraTransform = Float4x4.identity()
            * Float4x4.perspectiveProjection(fov: Float(60.0.toRadians()), aspect: aspect, nearPlane: 0.1, farPlane: 10.0)
            * (
            Float4x4.identity()
            * Float4x4(translateX: 0.0, y: 0.0, z: 0.1)
            * world.player.position.toTranslation()
            * Float4x4(rotateX: -(3 * .pi)/2)
            * (world.player.direction3d * Float4x4(scaleX: 1.0, y: 1.0, z: 1.0))
        ).inverse

        let worldTransform = Float4x4.identity()

        let texture = loadTexture(name: "Wall")

        renderables.forEach { (vertices, texCoords, objTransform, color, primitiveType) in
            let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])
            let coordsBuffer = device.makeBuffer(bytes: texCoords, length: MemoryLayout<Float2>.stride * texCoords.count, options: [])

            var pixelSize = 1

            var finalTransform = cameraTransform * worldTransform * objTransform

            encoder.setRenderPipelineState(texturePipeline)
            encoder.setDepthStencilState(depthStencilState)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<simd_float4x4>.stride, index: 3)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 4)

            var fragmentColor = Float3(color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.setFragmentTexture(texture, index: 0)
            encoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vertices.count)
        }
    }

    private func drawMap(world: World, encoder: MTLRenderCommandEncoder, cameraTransform: Float4x4, worldTransform: Float4x4) {
        //Draw map
        //TODO make this a type
        var renderables: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType)] = TileImage(map: world.map).tiles
        //Draw player
        renderables.append(world.player.rect.renderable())
        //Draw line of sight line
        let ray = Ray(origin: world.player.position, direction: world.player.direction)
        let end = world.map.hitTest(ray)
        renderables.append(
            ([
                world.player.position.toFloat3(),
                end.toFloat3()
            ], [], Float4x4.identity(), .green, .line)
        )
        //Draw view plane
        let focalLength: Float = 1.0
        let viewWidth: Float = 1.0
        let viewPlane = world.player.direction.orthogonal * viewWidth
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - viewPlane / 2
        let viewEnd = viewStart + viewPlane
        renderables.append(
            ([
                viewStart.toFloat3(),
                viewEnd.toFloat3()
            ], [], Float4x4.init(translateX: 0.0, y: 0.0, z: 0.0), .red, .line)
        )
        // Cast rays
        let columns = 300
        let step = viewPlane / Float(columns)
        var columnPosition = viewStart
        for _ in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)
            let end = world.map.hitTest(ray)
            renderables.append(
                ([
                    ray.origin.toFloat3(),
                    end.toFloat3()
                ], [], Float4x4.init(translateX: 0.0, y: 0.0, z: 0.0), .green, .line)
            )
            columnPosition += step
        }
        // Draw wall
//        step = viewPlane / Float(columns)
        columnPosition = viewStart
        let bitmapHeight = 1
        for x in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(
                origin: world.player.position,
                direction: rayDirection / viewPlaneDistance
            )
            let end = world.map.hitTest(ray)
            let wallDistance = (end - ray.origin).length

            // Draw wall
            let wallHeight:Float = 5.0
            let height = wallHeight * focalLength / wallDistance * Float(1.0)
            let wallColor: Color
            if end.x.rounded(.down) == end.x {
                wallColor = .white
            } else {
                wallColor = .grey
            }

            let drawWalls = false
            if (drawWalls) {
                renderables.append(
                    ([
                        Float3(x: Float(x), y: Float(bitmapHeight) - height, z: 0.0),
                        Float3(x: Float(x), y: Float(bitmapHeight) + height, z: 0.0),
                    ], [], Float4x4.identity()
                        * Float4x4.init(translateX: -7.0, y: 2.0, z: 0.0)
                        * Float4x4.init(scaleX: 0.1, y: 1.0, z: 1.0), wallColor, .line)
                )
            }
            columnPosition += step
        }

        renderables.forEach { (vertices, _, objTransform, color, primitiveType) in
            let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = cameraTransform * worldTransform * objTransform

            encoder.setRenderPipelineState(vertexPipeline)
            encoder.setCullMode(.back)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<simd_float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vertices.count)
        }
    }

    func loadTexture(name: String) -> MTLTexture? {
//        let loader = MTKTextureLoader(device: device)
//
//        let options: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft]
//
//        guard let url = Bundle.main.url(forResource: name, withExtension: "png") else {
//            print("Couldn't load the texture.")
//            return nil
//        }
//
//        let texture = try! loader.newTexture(URL: url, options: options)

        let textureLoader = MTKTextureLoader(device: device)

        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]

        return try! textureLoader.newTexture(name: name,
                                            scaleFactor: 1.0,
                                            bundle: nil,
                                            options: textureLoaderOptions)

//        return texture
    }
}

// Sitting with its bottom center on the origin
func LineCube(_ transformation: Float4x4 = Float4x4.identity()) -> [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType)] {
    return [
        (
            // xy z-0.5
            [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 1.0, -0.5),

                Float3(-0.5, 1.0, -0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ], [],
            transformation,
            .green,
            .line
        ),
        (
            // xy z1
            [
                Float3(-0.5, 0.0, 0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(-0.5, 0.0, 0.5),
            ], [],
            transformation,
            .red,
            .line
        ),
        (
             //xz y0
            [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, 0.5),

                Float3(-0.5, 0.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ], [],
            transformation,
            .blue,
            .line
        ),
        (
            //xz y1
            [
                Float3(-0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, -0.5),
            ], [],
            transformation,
            .white,
            .line
        )
    ]
}

