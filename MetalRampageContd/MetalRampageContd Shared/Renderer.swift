//
// Created by David Kanenwisher on 12/13/21.
//

import Foundation
import MetalKit

public class Renderer: NSObject {
    let view: MTKView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    private let pipelineCatalog: RNDRPipelineCatalog
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
    var titleScreen: [Texture:MTLTexture?] = [:]

    // models
    var model: [ModelLabel:Model] = [:]

    // static renderables
    var worldTiles: [(RNDRObject, Tile)]?
    var worldTilesBuffers: [MetalTileBuffers]?

    // draw phases
    private var drawWeapon: RNDRDrawWorldPhase?
    private var drawIndexedGameWorld: RNDRDrawIndexedGameWorld?

    // TODO do less stuff in init
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

        guard let depthStencilState = device.makeDepthStencilState(descriptor: MTLDepthStencilDescriptor().apply {
            $0.depthCompareFunction = .less
            $0.isDepthWriteEnabled = true
        }) else {
            fatalError("""
                       Agh?! The depth stencil state didn't work.
                       """)
        }

        self.depthStencilState = depthStencilState

        pipelineCatalog = RNDRPipelineCatalog(device: device)

        super.init()

        drawWeapon = RNDRDrawWeapon(renderer: self, pipelineCatalog: pipelineCatalog)
        drawIndexedGameWorld = RNDRDrawIndexedGameWorld(renderer: self, pipelineCatalog: pipelineCatalog)

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
        wand[.wandIcon] = loadTexture(name: "WandIcon")!
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
        fireBlast[.fireBlastIcon] = loadTexture(name: "FireBlastIcon")!
        hud[.crosshair] = loadTexture(name: "Crosshairs")!
        hud[.healthIcon] = loadTexture(name: "HealthIcon")!
        hud[.font] = loadTexture(name: "Font")!
        // TODO: I think the textures are loading in too dark
        titleScreen[.titleLogo] = loadTexture(name: "TitleLogo")!

        model[.unitSquare] = Model(
                                   vertices: [
                                       Float3(-0.5, -0.5, 0.0),
                                       Float3(-0.5, 0.5, 0.0),
                                       Float3(0.5, 0.5, 0.0),
                                       Float3(0.5, -0.5, 0.0),
                                   ],
                                   uv: [
                                       Float2(0.0, 1.0),
                                       Float2(0.0 ,0.0),
                                       Float2(1.0, 0.0),
                                       Float2(1.0, 1.0),
                                   ],
                                   index: [0, 1, 2, 2, 3, 0]
        )
    }

    public func updateAspect(width: Float, height: Float) {
        aspect = (width / height)
    }

    public func updateAspect(_ aspect: Float) {
        self.aspect = aspect
    }

    func render(_ game: Game) {
        let effects: [Effect] = (game.transition != nil) ? [game.transition!] : []
        switch game.state {
        case .title, .starting:
            render(game, additionalEffects: effects, onlyTitle: true)
        case .playing:
            render(game, additionalEffects: effects)
        }
    }

    private func render(_ game: Game, additionalEffects: [Effect] = [],onlyTitle: Bool = false) {
        if worldTiles == nil {
            worldTiles = (TileImage(world: game.world).tiles)
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

        let mapCamera = Float4x4.identity()
            * Float4x4.translate(x: -0.7, y: 0.9, z: 0.5)
                .scaledBy(x: 0.03, y: 0.03, z: 1.0)
                .scaledY(by: aspect)

        let playerCamera = Float4x4.identity()
            * Float4x4.perspectiveProjection(fov: Float(60.0.toRadians()), aspect: aspect, nearPlane: 0.1, farPlane: 20.0)
            * (Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: 0.0, z: 0.5) // move the camera to the middle of vertical tiles.
                * game.world.player.position.toTranslation() // move the camera
                * Float4x4.rotateX(.pi/2) // rotate the planes so that +x is right, +y is forward, and +z is down
                * (game.world.player.direction3d) // make sure the camera points out from the players
              ).inverse // flip all of these things around because the camera stays put while the world moves

        let hudCamera = Float4x4.identity()
                .scaledX(by: 1/aspect)

        if (onlyTitle) {
            drawTitleScreen(game: game, encoder: encoder, camera: hudCamera, pipelineCatalogue: pipelineCatalog)
        } else {

            drawReferenceMarkers(world: game.world, encoder: encoder, camera: playerCamera, pipelineCatalogue: pipelineCatalog)

            if game.world.drawWorld {
                drawIndexedGameWorld!.draw(world: game.world, encoder: encoder, camera: playerCamera)
            }

            drawIndexedSprites(world: game.world, encoder: encoder, camera: playerCamera, pipelineCatalogue: pipelineCatalog)

            if game.world.showMap {
                drawMap(world: game.world, encoder: encoder, camera: mapCamera, pipelineCatalogue: pipelineCatalog)
            }

            drawHud(hud: game.hud, encoder: encoder, camera: hudCamera, pipelineCatalogue: pipelineCatalog)

            drawWeapon!.draw(world: game.world, encoder: encoder, camera: hudCamera)
        }
        // always draw effects so the title screen can fade out
        drawEffects(effects: game.world.effects + additionalEffects, encoder: encoder, camera: playerCamera, pipelineCatalogue: pipelineCatalog)
        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func drawReferenceMarkers(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4, pipelineCatalogue: RNDRPipelineCatalog) {
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

            encoder.setRenderPipelineState(pipelineCatalogue.vertexPipeline)
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

    func drawIndexedSprites(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4, pipelineCatalogue: RNDRPipelineCatalog) {
        // TODO RNDRObject?
        var renderables: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType, Texture)] = []
        let model = model[.unitSquare]!

        renderables += world.sprites.map { billboard in
            (model.vertices, model.uv,
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
                , Color.black, MTLPrimitiveType.triangle, billboard.texture)
        }

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
            case .wall, .crackWall: // .crackWall can share with .wall for now
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

        let vertexBuffer = device.makeBuffer(bytes: model.vertices, length: MemoryLayout<Float3>.stride * model.vertices.count, options: [])
        let indexBuffer = device.makeBuffer(bytes: model.index, length: MemoryLayout<UInt16>.stride * model.index.count, options: [])!
        let coordsBuffer = device.makeBuffer(bytes: model.uv, length: MemoryLayout<Float2>.stride * model.uv.count, options: [])

        var pixelSize = 1

        var finalTransform = camera

        var fragmentColor = Float3(renderables[0].3)

        encoder.setRenderPipelineState(pipelineCatalogue.textureIndexedPipeline)
        encoder.setDepthStencilState(depthStencilState)
        // Setting this to none for now until I can figure out how to make doors draw on both sides.
        encoder.setCullMode(.none)

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)

        encoder.setFragmentBuffer(vertexBuffer, offset: 0, index: 0)
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
            type: renderables[0].4,
            indexCount: model.index.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            instanceCount: renderables.count
        )
    }

    private func drawHud(hud: Hud, encoder: MTLRenderCommandEncoder, camera: Float4x4, pipelineCatalogue: RNDRPipelineCatalog) {
        drawHealth(hud: hud, encoder: encoder, camera: camera)
        drawHudElements(hud: hud, encoder: encoder, camera: camera)
    }

    private func drawHealth(hud: Hud, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = model[.unitSquare]!

        let heartSpace: Float = 0.11
        // the hudCamera adjusts x by the aspect ratio so the x needs to be adjusted by the aspect here as well.
        let heartStart: Float2 = Float2(aspect * -0.9, 0.85)

        let playerHealth = String(hud.healthString).leftPadding(toLength: 3, withPad: "0")

        let healthTint: Color = hud.healthTint

        let heart1: (RNDRObject, Texture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 0, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .black,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .healthIcon, 100)

        let health1: (RNDRObject, Texture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 1, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: healthTint,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(playerHealth.charInt(at: 0) ?? 0)) ?? 0))

        let health2: (RNDRObject, Texture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 2, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: healthTint,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(playerHealth.charInt(at: 1) ?? 0)) ?? 0))

        let health3: (RNDRObject, Texture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 3, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: healthTint,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(playerHealth.charInt(at: 2) ?? 0)) ?? 0))

        var fontSpriteSheet = SpriteSheet(textureWidth: Float(hud.font.characters.count * 4), textureHeight: 6, spriteWidth: 4, spriteHeight: 6)
        var fontSpriteIndex = 0 // TODO let the shader select the sprite sheet

        var renderables: [(RNDRObject, Texture, UInt32?)] = []

        renderables.append(heart1)
        renderables.append(health1)
        renderables.append(health2)
        renderables.append(health3)

        let indexedObjTransform = renderables.map { (object, _, _) -> Float4x4 in object.transform }
        let indexedTextureId: [UInt32] = renderables.map { (_, texture, _) -> UInt32 in
            switch texture {
            case .crosshair:
                return 1
            case .healthIcon:
                return 2
            case .font:
                return 3
            case .fireBlastPickup:
                return 4
            case .wand:
                return 5
            default:
                return 0
            }
        }
        let indexedFontSpriteIndex: [UInt32] = renderables.map { (_, _, spriteIndex) -> UInt32 in spriteIndex ?? 100}
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let color = healthTint
        let primitiveType = renderables[0].0.primitiveType

        let buffer = device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let indexBuffer = device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])

        var pixelSize = 1

        var finalTransform = camera

        encoder.setRenderPipelineState(pipelineCatalog.textureIndexedSpriteSheetPipeline)
        encoder.setDepthStencilState(depthStencilState)
        // Setting this to none for now until I can figure out how to make doors draw on both sides.
        encoder.setCullMode(.none)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)
        encoder.setVertexBytes(&fontSpriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 6)
        encoder.setVertexBytes(&fontSpriteIndex, length: MemoryLayout<UInt32>.stride, index: 7)
        encoder.setVertexBytes(indexedFontSpriteIndex, length: MemoryLayout<UInt32>.stride * indexedFontSpriteIndex.count, index: 8)

        var fragmentColor = Float3(color)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(colorMapTexture!, index: 0)
        encoder.setFragmentTexture(self.hud[.crosshair]!, index: 1)
        encoder.setFragmentTexture(self.hud[.healthIcon]!, index: 2)
        encoder.setFragmentTexture(self.hud[.font]!, index: 3)
        encoder.setFragmentTexture(fireBlast[.fireBlastPickup]!, index: 4)
        encoder.setFragmentTexture(wand[.wand]!, index: 5)

        encoder.drawIndexedPrimitives(
            type: primitiveType,
            indexCount: index.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            instanceCount: renderables.count
        )
    }

    private func drawHudElements(hud: Hud, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = model[.unitSquare]!

        // TODO: Add Texture to RNDRObject?
        let crossHairs: (RNDRObject, Texture, UInt32?) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.scale(x: 0.25, y: 0.25, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .crosshair, nil)

        let fontSpace: Float = 0.10

        var fontSpriteSheet = SpriteSheet(textureWidth: 148, textureHeight: 6, spriteWidth: 4, spriteHeight: 6)
        //TODO pass a sprite index for instance being rendered
        //TODO find a way to pass whether a texture uses a sprite sheet
        var fontSpriteIndex = 0

        var renderables: [(RNDRObject, Texture, UInt32?)] = []
        renderables.append(crossHairs)

        let chargesStart: Float2 = Float2(aspect * 0.9, 0.85)

        let charges = String(Int(max(0, min(99, Int(hud.chargesString) ?? 0)))).leftPadding(toLength: 2, withPad: "0")

        let charges1: (RNDRObject, Texture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: chargesStart.x - fontSpace * 1, y: chargesStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(charges.charInt(at: 0) ?? 0)) ?? 0))

        let charges2: (RNDRObject, Texture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: chargesStart.x - fontSpace * 0, y: chargesStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(charges.charInt(at: 1) ?? 0)) ?? 0))

        let chargesIcon: (RNDRObject, Texture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: chargesStart.x - fontSpace * 2, y: chargesStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .black,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), hud.weaponIcon, 100)

        renderables.append(charges1)
        renderables.append(charges2)
        renderables.append(chargesIcon)

        let indexedObjTransform = renderables.map { (object, _, _) -> Float4x4 in object.transform }
        let indexedTextureId: [UInt32] = renderables.map { (_, texture, _) -> UInt32 in
            switch texture {
            case .crosshair:
                return 1
            case .healthIcon:
                return 2
            case .font:
                return 3
            case .fireBlastIcon:
                return 4
            case .wandIcon:
                return 5
            default:
                return 0
            }
        }
        let indexedFontSpriteIndex: [UInt32] = renderables.map { (_, _, spriteIndex) -> UInt32 in spriteIndex ?? 100}
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let color = renderables[0].0.color
        let primitiveType = renderables[0].0.primitiveType

        let buffer = device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let indexBuffer = device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])

        var pixelSize = 1

        var finalTransform = camera

        encoder.setRenderPipelineState(pipelineCatalog.textureIndexedSpriteSheetPipeline)
        // Setting this to none for now until I can figure out how to make doors draw on both sides.
        encoder.setCullMode(.none)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)
        encoder.setVertexBytes(&fontSpriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 6)
        encoder.setVertexBytes(&fontSpriteIndex, length: MemoryLayout<UInt32>.stride, index: 7)
        encoder.setVertexBytes(indexedFontSpriteIndex, length: MemoryLayout<UInt32>.stride * indexedFontSpriteIndex.count, index: 8)

        var fragmentColor = Float3(color)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(colorMapTexture!, index: 0)
        encoder.setFragmentTexture(self.hud[.crosshair]!, index: 1)
        encoder.setFragmentTexture(self.hud[.healthIcon]!, index: 2)
        encoder.setFragmentTexture(self.hud[.font]!, index: 3)
        encoder.setFragmentTexture(fireBlast[.fireBlastIcon]!, index: 4)
        encoder.setFragmentTexture(wand[.wandIcon]!, index: 5)

        encoder.drawIndexedPrimitives(
            type: primitiveType,
            indexCount: index.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            instanceCount: renderables.count
        )
    }

    private func drawTitleScreen(game: Game, encoder: MTLRenderCommandEncoder, camera: Float4x4, pipelineCatalogue: RNDRPipelineCatalog) {
        let model = model[.unitSquare]!

        var fontSpriteSheet = SpriteSheet(textureWidth: 148, textureHeight: 6, spriteWidth: 4, spriteHeight: 6)
        //TODO pass a sprite index for instance being rendered
        //TODO find a way to pass whether a texture uses a sprite sheet
        var fontSpriteIndex = 0

        // TODO: Add Texture to RNDRObject?
        let titleLogo: (RNDRObject, Texture, UInt32?) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.scale(x: 0.25, y: 0.25, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .titleLogo, nil)

        var renderables: [(RNDRObject, Texture, UInt32?)] = []
        renderables.append(titleLogo)

        for index in 0..<game.titleText.count {
            let character = game.titleText.char(at: index)!
            let text: (RNDRObject, Texture, UInt32) = (RNDRObject(
                vertices: model.allVertices(),
                uv: model.allUv(),
                transform: Float4x4.translate(x: (aspect * 0.0) + (-1 * Float(game.titleText.count - 1) / 2 * 0.01) + (0.01 * Float(index)) , y: -0.1, z: 0.0) * Float4x4.scale(x: 0.008, y: 0.01, z: 0.0),
                color: .yellow,
                primitiveType: .triangle,
                position: Int2(0, 0)
            ), .font, UInt32(game.hud.font.characters.firstIndex(of: String(character)) ?? 0))
            renderables.append(text)
        }

        let indexedObjTransform = renderables.map { (object, _, _) -> Float4x4 in object.transform }
        let indexedTextureId: [UInt32] = renderables.map { (_, texture, _) -> UInt32 in
            switch texture {
            case .font:
                return 3
            case .titleLogo:
                return 1
            default:
                return 0
            }
        }

        let indexedFontSpriteIndex: [UInt32] = renderables.map { (_, _, spriteIndex) -> UInt32 in spriteIndex ?? 100}
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let color = renderables[1].0.color
        let primitiveType = renderables[0].0.primitiveType

        let buffer = device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let indexBuffer = device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])

        var pixelSize = 1

        var finalTransform = camera * Float4x4.scale(x: 8.5 * aspect, y: 8.5, z: 0)

        encoder.setRenderPipelineState(pipelineCatalogue.textureIndexedSpriteSheetPipeline)
        // TODO why can't I have the depth stencil and the text on the bottom of the screen?
        // encoder.setDepthStencilState(depthStencilState)
        encoder.setCullMode(.none)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)
        encoder.setVertexBytes(&fontSpriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 6)
        encoder.setVertexBytes(&fontSpriteIndex, length: MemoryLayout<UInt32>.stride, index: 7)
        encoder.setVertexBytes(indexedFontSpriteIndex, length: MemoryLayout<UInt32>.stride * indexedFontSpriteIndex.count, index: 8)

        var fragmentColor = Float3(color)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(colorMapTexture!, index: 0)
        encoder.setFragmentTexture(titleScreen[.titleLogo]!, index: 1)
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

    private func drawEffects(effects: [Effect], encoder: MTLRenderCommandEncoder, camera: Float4x4, pipelineCatalogue: RNDRPipelineCatalog) {
        effects.forEach { effect in
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
                * Float4x4.scale(x: 2.0, y: 2.0, z: 0.0)
                * Float4x4.rotateY(-.pi)

            encoder.setCullMode(.back)
            encoder.setRenderPipelineState(pipelineCatalogue.effectPipeline)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = effect.asFloat4()
            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float4>.stride, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }
    }

    private func drawMap(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4, pipelineCatalogue: RNDRPipelineCatalog) {
        // TODO replace drawMap with an overheard view of the world
        //Draw map
        var renderables: [RNDRObject] = TileImage(world: world).tiles
                // filtering white tiles is a goofy shortcut so that only the floor tiles are used for the map
                // eventually this should be replaced with a proper overhead view of the world
                // going to need a way to rip off the ceiling or show only the floor for that
                .filter { $0.0.color == .white && ($0.1 == .crackWall || $0.1 == .wall || $0.1 == .slimeWall || $0.1 == .elevatorSideWall || $0.1 == .elevatorBackWall) }
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

        renderables.forEach { rndrObject in
            let buffer = device.makeBuffer(bytes: rndrObject.vertices, length: MemoryLayout<Float3>.stride * rndrObject.vertices.count, options: [])

            var pixelSize = 1

            var finalTransform =
                camera
                * Float4x4.scaleY(-1) // flip the map around the y axis
                * rndrObject.transform

            encoder.setRenderPipelineState(pipelineCatalogue.vertexPipeline)
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
            color: .green,
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
            color: .green,
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
            color: .green,
            primitiveType: .line,
            position: Int2 ()
        )
    ]
}

