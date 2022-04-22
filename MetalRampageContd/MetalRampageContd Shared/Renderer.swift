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
    let textureIndexedPipeline: MTLRenderPipelineState
    let textureIndexedSpriteSheetPipeline: MTLRenderPipelineState
    let vertexPipeline: MTLRenderPipelineState
    let effectPipeline: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    // need to pass the aspect ratio to the new renderer
    private(set) var aspect: Float = 1.0

    // textures
    var ceiling: MTLTexture!
    var colorMapTexture: MTLTexture!
    var crackedFloor: MTLTexture!
    var crackedWallTexture: MTLTexture!
    var floor: MTLTexture!
    var slimeWallTexture: MTLTexture!
    var wallTexture: MTLTexture!
    var monster: [Texture:MTLTexture?] = [:]
    var wand: [Texture:MTLTexture?] = [:]
    var wandFiring1: [Texture:MTLTexture?] = [:]
    var wandFiring2: [Texture:MTLTexture?] = [:]
    var wandFiring3: [Texture:MTLTexture?] = [:]
    var wandFiring4: [Texture:MTLTexture?] = [:]
    var door: [Texture:MTLTexture?] = [:]
    var doorJamb: [Texture:MTLTexture?] = [:]
    var wallSwitch: [Texture:MTLTexture?] = [:]
    var healingPotionTexture: MTLTexture!
    var fireBlast: [Texture:MTLTexture?] = [:]
    var hud: [Texture:MTLTexture?] = [:]

    // static renderables
    var worldTiles: [(RNDRObject, Tile)]?
    var worldTilesBuffers: [MetalTileBuffers]?

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

        super.init()

        ceiling = loadTexture(name: "Ceiling")!
        colorMapTexture = loadTexture(name: "ColorMap")!
        crackedFloor = loadTexture(name: "CrackedFloor")!
        crackedWallTexture = loadTexture(name: "CrackedWall")!
        floor = loadTexture(name: "Floor")!
        slimeWallTexture = loadTexture(name: "SlimeWall")!
        wallTexture = loadTexture(name: "Wall")!
        monster[.monster] = loadTexture(name: "Monster")!
        monster[.monsterWalk1] = loadTexture(name: "MonsterWalk1")!
        monster[.monsterWalk2] = loadTexture(name: "MonsterWalk2")!
        monster[.monsterScratch1] = loadTexture(name: "MonsterScratch1")!
        monster[.monsterScratch2] = loadTexture(name: "MonsterScratch2")!
        monster[.monsterScratch3] = loadTexture(name: "MonsterScratch3")!
        monster[.monsterScratch4] = loadTexture(name: "MonsterScratch4")!
        monster[.monsterScratch5] = loadTexture(name: "MonsterScratch5")!
        monster[.monsterScratch6] = loadTexture(name: "MonsterScratch6")!
        monster[.monsterScratch7] = loadTexture(name: "MonsterScratch6")!
        monster[.monsterScratch8] = loadTexture(name: "MonsterScratch8")!
        monster[.monsterHurt] = loadTexture(name: "MonsterHurt")!
        monster[.monsterDeath1] = loadTexture(name: "MonsterDeath1")!
        monster[.monsterDeath2] = loadTexture(name: "MonsterDeath2")!
        monster[.monsterDead] = loadTexture(name: "MonsterDead")!
        wand[.wand] = loadTexture(name: "Wand")!
        wand[.wandFiring1] = loadTexture(name: "WandFiring1")!
        wand[.wandFiring2] = loadTexture(name: "WandFiring2")!
        wand[.wandFiring3] = loadTexture(name: "WandFiring3")!
        wand[.wandFiring4] = loadTexture(name: "WandFiring4")!
        door[.door1] = loadTexture(name: "Door1")!
        door[.door2] = loadTexture(name: "Door2")!
        doorJamb[.doorJamb1] = loadTexture(name: "DoorJamb1")!
        doorJamb[.doorJamb2] = loadTexture(name: "DoorJamb2")!
        wallSwitch[.switch1] = loadTexture(name: "Switch1")!
        wallSwitch[.switch2] = loadTexture(name: "Switch2")!
        wallSwitch[.switch3] = loadTexture(name: "Switch3")!
        wallSwitch[.switch4] = loadTexture(name: "Switch4")!
        healingPotionTexture = loadTexture(name: "HealingPotion")!
        fireBlast[.fireBlastPickup] = loadTexture(name: "FireBlastPickup")!
        fireBlast[.fireBlastIdle] = loadTexture(name: "FireBlastIdle")!
        fireBlast[.fireBlastFire1] = loadTexture(name: "FireBlastFire1")!
        fireBlast[.fireBlastFire2] = loadTexture(name: "FireBlastFire2")!
        fireBlast[.fireBlastFire3] = loadTexture(name: "FireBlastFire3")!
        fireBlast[.fireBlastFire4] = loadTexture(name: "FireBlastFire4")!
        hud[.crosshair] = loadTexture(name: "Crosshairs")!
        hud[.healthIcon] = loadTexture(name: "HealthIcon")!
        hud[.font] = loadTexture(name: "Font")!
    }

    public func updateAspect(width: Float, height: Float) {
        aspect = (width / height)
    }

    public func updateAspect(_ aspect: Float) {
        self.aspect = aspect
    }

    public func render(_ world: World) {

        if worldTiles == nil {
            worldTiles = (TileImage(world: world).tiles)
        }

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

        let worldTransform = Float4x4.scaleY(-1)

        let mapCamera = Float4x4.identity()
            * Float4x4.translate(x: -0.7, y: 0.9, z: 0)
                .scaledBy(x: 0.03, y: 0.03, z: 1.0)
                .scaledY(by: aspect)

        let playerCamera = Float4x4.identity()
            * Float4x4.perspectiveProjection(fov: Float(60.0.toRadians()), aspect: aspect, nearPlane: 0.1, farPlane: 20.0)
            * (Float4x4.identity()
                .scaledBy(x: 0.2, y: 0.2, z: 0.2)
                * Float4x4.translate(x: 0.0, y: 0.0, z: 0.5)
                * world.player.position.toTranslation()
                * Float4x4.rotateX(-(3 * .pi)/2)
                * (world.player.direction3d.scaledBy(x: 1.0, y: 1.0, z: 1.0))
              ).inverse

        let hudCamera = Float4x4.identity()
                .scaledX(by: 1/aspect)

        drawReferenceMarkers(world: world, encoder: encoder, camera: playerCamera)

        if world.drawWorld {
            drawIndexedGameworld(world: world, encoder: encoder, camera: playerCamera)
        }

        drawIndexedSprites(world: world, encoder: encoder, camera: playerCamera)

        if world.showMap {
            drawMap(world: world, encoder: encoder, camera: mapCamera, worldTransform: worldTransform)
        }

        drawHud(world: world, encoder: encoder, camera: hudCamera, worldTransform: worldTransform)

        drawWeapon(world: world, encoder: encoder, camera: hudCamera, worldTransform: worldTransform)

        drawEffects(world: world, encoder: encoder, camera: playerCamera, worldTransform: worldTransform)

        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func drawReferenceMarkers(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        var renderables: [RNDRObject] = []

        renderables += LineCube(Float4x4.scale(x: 0.1, y: 0.1, z: 0.1))
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 1.0, y: 0.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: -1.0, y: 0.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: 1.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: -1.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: 0.0, z: 1.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: 0.0, z: -1.0)
                .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        let worldTransform = Float4x4.identity()

        renderables.forEach { rndrObject in
            let buffer = device.makeBuffer(bytes: rndrObject.vertices, length: MemoryLayout<Float3>.stride * rndrObject.vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = camera * worldTransform * rndrObject.transform

            encoder.setRenderPipelineState(vertexPipeline)
            encoder.setDepthStencilState(depthStencilState)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(rndrObject.color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: rndrObject.primitiveType, vertexStart: 0, vertexCount: rndrObject.vertices.count)
        }
    }

    func drawIndexedSprites(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        // TODO RNDRObject?
        var renderables: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType, Texture)] = []

        renderables += world.sprites.map { billboard in
            ([
                Float3(-0.5, -0.5, 0.0), // lower left
                Float3(0.5, 0.5, 0.0), // upper right
                Float3(-0.5, 0.5, 0.0), // upper left
                Float3(0.5, -0.5, 0.0), // lower right
            ], [
                Float2(1.0,1.0),
                Float2(0.0,0.0),
                Float2(1.0,0.0),
                Float2(0.0,1.0),
            ],
                Float4x4.identity()
                    * Float4x4.translate(x: Float(billboard.position.x), y: Float(billboard.position.y), z: 0.5)
                    * (Float4x4.identity()
                    * Float4x4.rotateX(-(3 * .pi)/2)
                    * Float4x4.rotateY(.pi / 2)
                    // use atan2 to convert the direction vector to an angle
                    // this works because these sprites only rotate about the y axis.
                    * Float4x4.rotateY(atan2(billboard.direction.y, billboard.direction.x))
                    * Float4x4.rotateY(.pi/2)
                )
                , Color.red, MTLPrimitiveType.triangle, billboard.texture)
        }

        let worldTransform = Float4x4.scale(x: 0.2, y: 0.2, z: 0.2)

        // if there's nothing to render bail out
        guard renderables.count > 0 else {
            return
        }

        let indexedObjTransform = renderables.map { _, _, transform, _, _, _ -> Float4x4 in transform }
        let indexedTextureId: [UInt32] = world.sprites.map { (billboard) -> UInt32 in
            switch billboard.texture {
            case .monster:
                return 0
            case .monsterWalk1:
                return 1
            case .monsterWalk2:
                return 2
            case .monsterScratch1:
                return 3
            case .monsterScratch2:
                return 4
            case .monsterScratch3:
                return 5
            case .monsterScratch4:
                return 6
            case .monsterScratch5:
                return 7
            case .monsterScratch6:
                return 8
            case .monsterScratch7:
                return 9
            case .monsterScratch8:
                return 10
            case .monsterHurt:
                return 11
            case .monsterDeath1:
                return 12
            case .monsterDeath2:
                return 13
            case .monsterDead:
                return 14
            case .door1:
                return 15
            case .door2:
                 return 16
            case .wall:
                return 17
            case .slimeWall:
                return 18
            case .healingPotion:
                return 19
            case .fireBlastPickup:
                return 20
            default:
                return 0
            }
        }

        let index: [UInt16] = [0, 1, 2, 0, 3, 1]

        let vertices = renderables[0].0
        let texCoords = renderables[0].1
        let color = renderables[0].3
        let primitiveType = renderables[0].4

        let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])
        let indexBuffer = device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = device.makeBuffer(bytes: texCoords, length: MemoryLayout<Float2>.stride * texCoords.count, options: [])

        var pixelSize = 1

        var finalTransform = camera * worldTransform

        encoder.setRenderPipelineState(textureIndexedPipeline)
        encoder.setDepthStencilState(depthStencilState)
        // Setting this to none for now until I can figure out how to make doors draw on both sides.
        encoder.setCullMode(.none)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)

        var fragmentColor = Float3(color)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(monster[.monster]!, index: 0)
        encoder.setFragmentTexture(monster[.monsterWalk1]!, index: 1)
        encoder.setFragmentTexture(monster[.monsterWalk2]!, index: 2)
        encoder.setFragmentTexture(monster[.monsterScratch1]!, index: 3)
        encoder.setFragmentTexture(monster[.monsterScratch2]!, index: 4)
        encoder.setFragmentTexture(monster[.monsterScratch3]!, index: 5)
        encoder.setFragmentTexture(monster[.monsterScratch4]!, index: 6)
        encoder.setFragmentTexture(monster[.monsterScratch5]!, index: 7)
        encoder.setFragmentTexture(monster[.monsterScratch6]!, index: 8)
        encoder.setFragmentTexture(monster[.monsterScratch7]!, index: 9)
        encoder.setFragmentTexture(monster[.monsterScratch8]!, index: 10)
        encoder.setFragmentTexture(monster[.monsterHurt]!, index: 11)
        encoder.setFragmentTexture(monster[.monsterDeath1]!, index: 12)
        encoder.setFragmentTexture(monster[.monsterDeath2]!, index: 13)
        encoder.setFragmentTexture(monster[.monsterDead]!, index: 14)
        encoder.setFragmentTexture(door[.door1]!, index: 15)
        encoder.setFragmentTexture(door[.door2]!, index: 16)
        encoder.setFragmentTexture(wallTexture!, index: 17)
        encoder.setFragmentTexture(slimeWallTexture!, index: 18)
        encoder.setFragmentTexture(healingPotionTexture!, index: 19)
        encoder.setFragmentTexture(fireBlast[.fireBlastPickup]!, index: 20)
        encoder.drawIndexedPrimitives(
            type: primitiveType,
            indexCount: index.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            instanceCount: renderables.count
        )
    }

    private func drawIndexedGameworld(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let worldTransform = Float4x4.scale(x: 0.2, y: 0.2, z: 0.2)

        let color = Color.blue
        let primitiveType = MTLPrimitiveType.triangle

        if worldTilesBuffers == nil {
            initializeWorldTilesBuffer(world: world)
        }

        worldTilesBuffers?.forEach { buffers in
            let buffer = buffers.vertexBuffer
            let indexBuffer = buffers.indexBuffer
            let coordsBuffer = buffers.uvBuffer
            let indexedObjTransform = buffers.indexedTransformations
            let indexedTextureId: [UInt] = buffers.indexedTransformations.map { _ in 0 }

            var pixelSize = 1

            var finalTransform = camera * worldTransform

            var texture: MTLTexture = colorMapTexture

            switch(buffers.tile) {
            case .wall, .elevatorBackWall, .elevatorSideWall:
                texture = wallTexture
            case .crackWall:
                texture = crackedWallTexture
            case .slimeWall:
                texture = slimeWallTexture
            case .floor, .elevatorFloor:
                texture = floor
            case .crackFloor:
                texture = crackedFloor
            case .ceiling:
                texture = ceiling
            case .doorJamb1:
                texture = doorJamb[.doorJamb1]!!
            case .doorJamb2:
                texture = doorJamb[.doorJamb2]!!
            case .wallSwitch:
                // wall switch can animate so check to see if the texture has changed
                //TODO this is a little bit ugly
                buffers.positions.forEach { position in
                    if let s = world.switch(at: Int(position.x), Int(position.y)) {
                        texture = wallSwitch[s.animation.texture]!!
                    }
                }
            default:
                texture = colorMapTexture
            }

            encoder.setRenderPipelineState(textureIndexedPipeline)
            encoder.setDepthStencilState(depthStencilState)
            encoder.setCullMode(.back)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
            encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
            encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt>.stride * indexedTextureId.count, index: 5)

            var fragmentColor = Float3(color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.setFragmentTexture(texture, index: 0)
            encoder.drawIndexedPrimitives(
                type: primitiveType,
                indexCount: buffers.indexCount,
                indexType: .uint16,
                indexBuffer: indexBuffer,
                indexBufferOffset: 0,
                instanceCount: buffers.tileCount
            )
        }
    }

    private func drawWeapon(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4, worldTransform: Float4x4) {
        let vertices = [
            Float3(0.0, 0.0, 0.0),
            Float3(0.0, 1.0, 0.0),
            Float3(1.0, 1.0, 0.0),

            Float3(1.0, 1.0, 0.0),
            Float3(1.0, 0.0, 0.0),
            Float3(0.0, 0.0, 0.0),
        ]

        let  uvCoords = [
            Float2(0.0, 1.0),
            Float2(0.0 ,0.0),
            Float2(1.0, 0.0),
            Float2(1.0, 0.0),
            Float2(1.0, 1.0),
            Float2(0.0, 1.0),
        ]

        let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])
        let coordsBuffer = device.makeBuffer(bytes: uvCoords, length: MemoryLayout<Float2>.stride * uvCoords.count, options: [])!

        // select the texture
        var textureId: UInt32
        switch world.player.animation.texture {
        case .wand:
            textureId = 0
        case .wandFiring1:
            textureId = 1
        case .wandFiring2:
            textureId = 2
        case .wandFiring3:
            textureId = 3
        case .wandFiring4:
            textureId = 4
        case .fireBlastIdle:
            textureId = 5
        case .fireBlastFire1:
            textureId = 6
        case .fireBlastFire2:
            textureId = 7
        case .fireBlastFire3:
            textureId = 8
        case .fireBlastFire4:
             textureId = 9
        default:
            textureId = 0
        }

        var pixelSize = 1

        var finalTransform = camera
            * Float4x4.translate(x: -1.0, y: -1.0, z: 0.1)
            * Float4x4.scale(x: 2.0, y: 2.0, z: 0.0)

        encoder.setRenderPipelineState(texturePipeline)
        encoder.setDepthStencilState(depthStencilState)
        encoder.setCullMode(.back)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 3)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 4)
        encoder.setVertexBytes(&textureId, length: MemoryLayout<Float>.stride, index: 5)

        let color = Color.red
        var fragmentColor = Float4(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(wand[.wand]!, index: 0)
        encoder.setFragmentTexture(wand[.wandFiring1]!, index: 1)
        encoder.setFragmentTexture(wand[.wandFiring2]!, index: 2)
        encoder.setFragmentTexture(wand[.wandFiring3]!, index: 3)
        encoder.setFragmentTexture(wand[.wandFiring4]!, index: 4)
        encoder.setFragmentTexture(fireBlast[.fireBlastIdle]!, index: 5)
        encoder.setFragmentTexture(fireBlast[.fireBlastFire1]!, index: 6)
        encoder.setFragmentTexture(fireBlast[.fireBlastFire2]!, index: 7)
        encoder.setFragmentTexture(fireBlast[.fireBlastFire3]!, index: 8)
        encoder.setFragmentTexture(fireBlast[.fireBlastFire4]!, index: 9)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }

    private func drawHud(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4, worldTransform: Float4x4) {
        // TODO put this somewhere shareable
        // TODO reduce to 4 vertices when indexed
        // a centered square
        let vertices = [
            Float3(-0.5, -0.5, -0.5),
            Float3(-0.5, 0.5, -0.5),
            Float3(0.5, 0.5, -0.5),

            Float3(0.5, 0.5, -0.5),
            Float3(0.5, -0.5, -0.5),
            Float3(-0.5, -0.5, -0.5),
        ]

        let uvX: Float = 0.0
        let  uvCoords = [
            Float2(0.0, 1.0),
            Float2(0.0 ,0.0),
            Float2(1.0, 0.0),
            Float2(1.0, 0.0),
            Float2(1.0, 1.0),
            Float2(0.0 , 1.0),
        ]
                //.map { ($0.toFloat3() * Float3x3.translate(x: -0.9, y: 0) * Float3x3.scale(x: 1.0, y: 1.0)).toFloat2() }

        // TODO: Add Texture to RNDRObject?
        let crossHairs: (RNDRObject, Texture) = (RNDRObject(
            vertices: vertices,
            uv: uvCoords,
            transform: Float4x4.scale(x: 0.25, y: 0.25, z: 0.0),
            color: .red,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .crosshair)

        let heartSpace: Float = 0.11
        // the hudCamera adjusts x by the aspect ratio so the x needs to be adjusted by the aspect here as well.
        let heartStart: Float2 = Float2(aspect * -0.95, 0.95)

        let heart1: (RNDRObject, Texture) = (RNDRObject(
            vertices: vertices,
            uv: uvCoords,
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 0, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .red,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .healthIcon)

        let heart2: (RNDRObject, Texture) = (RNDRObject(
            vertices: vertices,
            uv: uvCoords,
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 1, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .red,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .healthIcon)

        let heart3: (RNDRObject, Texture) = (RNDRObject(
            vertices: vertices,
            uv: uvCoords,
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 2, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .red,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .healthIcon)

        let heart4: (RNDRObject, Texture) = (RNDRObject(
            vertices: vertices,
            uv: uvCoords,
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 3, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.05, y: 0.1, z: 0.0),
            color: .red,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font)

        var fontSpriteSheet = SpriteSheet(textureWidth: 40, textureHeight: 6, spriteWidth: 4, spriteHeight: 6)
        var fontSpriteIndex: UInt32 = 0

        var renderables: [(RNDRObject, Texture)] = []
        renderables.append(crossHairs)
        let health = world.player.health
        if health > 0 {
            renderables.append(heart1)
        }
        if health > 25 {
            renderables.append(heart2)
        }
        if health > 50 {
            renderables.append(heart3)
        }
        if health > 75 {
            renderables.append(heart4)
        }

        let indexedObjTransform = renderables.map { (object, _) -> Float4x4 in object.transform }
        let indexedTextureId: [UInt32] = renderables.map { (_, texture) -> UInt32 in
            switch texture {
            case .crosshair:
                return 1
            case .healthIcon:
                return 2
            case .font:
                return 3
            default:
                return 0
            }
        }
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let color = renderables[0].0.color
        let primitiveType = renderables[0].0.primitiveType

        let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])
        let indexBuffer = device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = device.makeBuffer(bytes: uvCoords, length: MemoryLayout<Float2>.stride * uvCoords.count, options: [])

        var pixelSize = 1

        var finalTransform = camera

        encoder.setRenderPipelineState(textureIndexedSpriteSheetPipeline)
        encoder.setDepthStencilState(depthStencilState)
        // Setting this to none for now until I can figure out how to make doors draw on both sides.
        encoder.setCullMode(.none)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)

        var fragmentColor = Float3(color)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentBytes(&fontSpriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 1)
        encoder.setFragmentBytes(&fontSpriteIndex, length: MemoryLayout<UInt32>.stride, index: 2)
        encoder.setFragmentTexture(colorMapTexture!, index: 0)
        encoder.setFragmentTexture(hud[.crosshair]!, index: 1)
        encoder.setFragmentTexture(hud[.healthIcon]!, index: 2)
        encoder.setFragmentTexture(hud[.font]!, index: 3)

        encoder.drawIndexedPrimitives(
            type: primitiveType,
            indexCount: index.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            instanceCount: renderables.count
        )
    }


    private func drawEffects(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4, worldTransform: Float4x4) {
        world.effects.forEach { effect in
            let vertices = [
                Float3(0.0, 0.0, 0.0),
                Float3(1.0, 1.0, 0.0),
                Float3(0.0, 1.0, 0.0),

                Float3(0.0, 0.0, 0.0),
                Float3(1.0, 0.0, 0.0),
                Float3(1.0, 1.0, 0.0),
            ]

            let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = Float4x4.identity()
                * Float4x4.translate(x: 1.0, y: -1.0, z: 0.0)
                * Float4x4.scale(x: 2.0, y: 2.0, z: 1.99)
                * Float4x4.rotateY(-.pi)

            encoder.setCullMode(.back)
            encoder.setRenderPipelineState(effectPipeline)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = effect.asFloat4()
            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float4>.stride, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }
    }

    private func initializeWorldTilesBuffer(world: World) {
        worldTilesBuffers = Array()
        let index: [UInt16] = [0, 1, 2, 0, 3, 1]

        // is something getting flipped somewhere?
        let  uvCoords = [
            Float2(0.0,0.0),
            Float2(1.0,1.0),
            Float2(1.0,0.0),
            Float2(0.0,1.0),
        ]

        let vertices = [
            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 1.0, 0.0),
            Float3(0.0, 1.0, 0.0),
            Float3(1.0, 0.0, 0.0),
        ]

        Tile.allCases.forEach { tile in
            worldTiles!.filter {$0.1 == tile}.chunked(into: 64).forEach { chunk in
                let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])!
                let indexBuffer = device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
                let coordsBuffer = device.makeBuffer(bytes: uvCoords, length: MemoryLayout<Float2>.stride * uvCoords.count, options: [])!
                let indexedObjTransform = chunk.map { (rndrObject, _)-> Float4x4 in
                    rndrObject.transform
                }
                worldTilesBuffers?.append(
                    MetalTileBuffers(
                        vertexBuffer: buffer,
                        indexBuffer: indexBuffer,
                        uvBuffer: coordsBuffer,
                        indexedTransformations: indexedObjTransform,
                        tile: tile,
                        tileCount: chunk.count,
                        index: index,
                        indexCount: index.count,
                        positions:  chunk.map { (rndrObject, _) -> Int2 in rndrObject.position }
                    )
                )
            }
        }
    }

    private func drawMap(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4, worldTransform: Float4x4) {
        //Draw map
        var renderables: [RNDRObject] = TileImage(world: world).tiles
                .filter { $0.1 == .crackWall || $0.1 == .wall || $0.1 == .slimeWall || $0.1 == .elevatorSideWall || $0.1 == .elevatorBackWall }
                .map { $0.0 }
        //Draw player
        renderables.append(world.player.rect.renderableObject())

        //Draw view plane
        let focalLength: Float = 1.0
        let viewWidth: Float = 1.0
        let viewPlane = world.player.direction.orthogonal * viewWidth
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - viewPlane / 2
        let viewEnd = viewStart + viewPlane
        renderables.append(
            RNDRObject(vertices: [
                viewStart.toFloat3(),
                viewEnd.toFloat3()
            ], uv: [], transform: Float4x4.translate(x: 0.0, y: 0.0, z: 0.0), color: .red, primitiveType: .line, position: Int2())
        )
        // Cast rays
        let columns = 3
        let step = viewPlane / Float(columns)
        var columnPosition = viewStart
        for _ in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)

            var end = world.map.hitTest(ray)
            for sprite in world.sprites {
                guard let hit = sprite.hitTest(ray) else {
                    continue
                }
                let spriteDistance = (hit - ray.origin).length
                if spriteDistance > (end - ray.origin).length {
                    continue
                }
                end = hit
            }

            renderables.append(
                RNDRObject(vertices: [
                    ray.origin.toFloat3(),
                    end.toFloat3()
                ], uv: [], transform: Float4x4.translate(x: 0.0, y: 0.0, z: 0.0), color: .green, primitiveType: .line, position: Int2())
            )
            columnPosition += step
        }

        // Draw sprites
        for line in world.sprites {
            renderables.append(
                RNDRObject(vertices: [
                    line.start.toFloat3(),
                    line.end.toFloat3()
                ], uv: [], transform: Float4x4.translate(x: 0.0, y: 0.0, z: 0.0), color: .green, primitiveType: .line, position: Int2())
            )
        }

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


            let drawWalls = false
            if (drawWalls) {
                let wallHeight:Float = 5.0
                let height = wallHeight * focalLength / wallDistance * Float(1.0)
                let wallColor: Color
                if end.x.rounded(.down) == end.x {
                    wallColor = .white
                } else {
                    wallColor = .grey
                }
                renderables.append(
                    RNDRObject(vertices: [
                        Float3(x: Float(x), y: Float(bitmapHeight) - height, z: 0.0),
                        Float3(x: Float(x), y: Float(bitmapHeight) + height, z: 0.0),
                    ], uv: [], transform: Float4x4.translate(x: -7.0, y: 2.0, z: 0.0).scaledBy(x: 0.1, y: 1.0, z: 1.0), color: wallColor, primitiveType: .line, position: Int2())
                )
            }
            columnPosition += step
        }

        renderables.forEach { rndrObject in
            let buffer = device.makeBuffer(bytes: rndrObject.vertices, length: MemoryLayout<Float3>.stride * rndrObject.vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = camera * worldTransform * rndrObject.transform

            encoder.setRenderPipelineState(vertexPipeline)
            encoder.setCullMode(.back)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(rndrObject.color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: rndrObject.primitiveType, vertexStart: 0, vertexCount: rndrObject.vertices.count)
        }
    }

    func loadTexture(name: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)

        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]

        return try! textureLoader.newTexture(name: name,
                                            scaleFactor: 1.0,
                                            bundle: nil,
                                            options: textureLoaderOptions)

    }
}

// TODO Find a home for this
// Sitting with its bottom center on the origin
func LineCube(_ transformation: Float4x4 = Float4x4.identity()) -> [RNDRObject] {
    return [
        RNDRObject(
            // xy z-0.5
            vertices: [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 1.0, -0.5),

                Float3(-0.5, 1.0, -0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ], uv: [],
            transform: transformation,
            color: .green,
            primitiveType: .line,
            position: Int2()
        ),
        RNDRObject(
            // xy z1
            vertices: [
                Float3(-0.5, 0.0, 0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(-0.5, 0.0, 0.5),
            ], uv: [],
            transform: transformation,
            color: .red,
            primitiveType: .line,
            position: Int2()
        ),
        RNDRObject(
             //xz y0
            vertices: [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, 0.5),

                Float3(-0.5, 0.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ], uv: [],
            transform: transformation,
            color: .blue,
            primitiveType: .line,
            position: Int2()
        ),
        RNDRObject(
            //xz y1
            vertices: [
                Float3(-0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, -0.5),
            ], uv: [],
            transform: transformation,
            color: .white,
            primitiveType: .line,
            position: Int2 ()
        )
    ]
}

