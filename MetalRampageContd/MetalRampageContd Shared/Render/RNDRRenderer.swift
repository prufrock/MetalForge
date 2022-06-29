//
// Created by David Kanenwisher on 12/13/21.
//

import Foundation
import MetalKit

class RNDRRenderer: NSObject {
    private let view: MTKView
    let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineCatalog: RNDRPipelineCatalog
    let depthStencilState: MTLDepthStencilState
    // need to pass the aspect ratio to the new renderer
    private(set) var aspect: Float = 1.0

    // textures
    private(set) var ceiling: MTLTexture!
    private(set) var colorMapTexture: MTLTexture!
    private(set) var crackedFloor: MTLTexture!
    private(set) var crackedWallTexture: MTLTexture!
    private(set) var floor: MTLTexture!
    private(set) var slimeWallTexture: MTLTexture!
    private(set) var wallTexture: MTLTexture!
    private(set) var monster: [GMTexture:MTLTexture?] = [:]
    private(set) var wand: [GMTexture:MTLTexture?] = [:]
    private(set) var wandFiring1: [GMTexture:MTLTexture?] = [:]
    private(set) var wandFiring2: [GMTexture:MTLTexture?] = [:]
    private(set) var wandFiring3: [GMTexture:MTLTexture?] = [:]
    private(set) var wandFiring4: [GMTexture:MTLTexture?] = [:]
    private(set) var door: [GMTexture:MTLTexture?] = [:]
    private(set) var doorJamb: [GMTexture:MTLTexture?] = [:]
    private(set) var wallSwitch: [GMTexture:MTLTexture?] = [:]
    private(set) var healingPotionTexture: MTLTexture!
    private(set) var fireBlast: [GMTexture:MTLTexture?] = [:]
    private(set) var hud: [GMTexture:MTLTexture?] = [:]
    private(set) var titleScreen: [GMTexture:MTLTexture?] = [:]

    // models
    private(set) var model: [ModelLabel:RNDRModel] = [:]

    // static renderables
    private(set) var worldTiles: [(RNDRObject, GMTile)]?
    var worldTilesBuffers: [RNDRMetalTileBuffers]?

    // draw phases
    private var drawWeapon: RNDRDrawWorldPhase?
    private var drawIndexedGameWorld: RNDRDrawWorldPhase?
    private var drawIndexedSprites: RNDRDrawWorldPhase?
    private var drawReferenceMarkers: RNDRDrawWorldPhase?
    private var drawMap: RNDRDrawWorldPhase?
    private var drawHealth: RNDRDrawHudPhase?
    private var drawHudElements: RNDRDrawHudPhase?
    private var drawEffects: RNDRDrawEffects?
    private var drawTitleScreen: RNDRDrawTitleScreen?

    // TODO do less stuff in init
    init(_ view: MTKView, width: Int, height: Int) {
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
        drawIndexedSprites = RNDRDrawIndexedSprites(renderer: self, pipelineCatalog: pipelineCatalog)
        drawReferenceMarkers = RNDRDrawReferenceMarkers(renderer: self, pipelineCatalog: pipelineCatalog)
        drawMap = RNDRDrawMap(renderer: self, pipelineCatalog: pipelineCatalog)
        drawHealth = RNDRDrawHealth(renderer: self, pipelineCatalog: pipelineCatalog)
        drawHudElements = RNDRDrawHudElements(renderer: self, pipelineCatalog: pipelineCatalog)
        drawEffects = RNDRDrawEffects(renderer: self, pipelineCatalog: pipelineCatalog)
        drawTitleScreen = RNDRDrawTitleScreen(renderer: self, pipelineCatalog: pipelineCatalog)

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
        titleScreen[.titleLogo] = loadTexture(name: "TitleLogo")!

        model[.unitSquare] = unitSquare()
    }

    func updateAspect(width: Float, height: Float) {
        aspect = (width / height)
    }

    func updateAspect(_ aspect: Float) {
        self.aspect = aspect
    }

    func render(_ game: GMGame) {
        let effects: [GMEffect] = (game.transition != nil) ? [game.transition!] : []
        switch game.state {
        case .title, .starting:
            render(game, additionalEffects: effects, onlyTitle: true)
        case .playing:
            render(game, additionalEffects: effects)
        }
    }

    private func render(_ game: GMGame, additionalEffects: [GMEffect] = [],onlyTitle: Bool = false) {
        if worldTiles == nil {
            worldTiles = (RNDRTileImage(world: game.world).tiles)
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
            drawTitleScreen!.draw(game: game, encoder: encoder, camera: hudCamera)
        } else {

            drawReferenceMarkers!.draw(world: game.world, encoder: encoder, camera: playerCamera)

            if game.world.drawWorld {
                drawIndexedGameWorld!.draw(world: game.world, encoder: encoder, camera: playerCamera)
            }

            drawIndexedSprites!.draw(world: game.world, encoder: encoder, camera: playerCamera)

            if game.world.showMap {
                drawMap!.draw(world: game.world, encoder: encoder, camera: mapCamera)
            }

            // draw the hud
            drawHealth!.draw(hud: game.hud, encoder: encoder, camera: hudCamera)
            drawHudElements!.draw(hud: game.hud, encoder: encoder, camera: hudCamera)

            drawWeapon!.draw(world: game.world, encoder: encoder, camera: hudCamera)
        }
        // always draw effects so the title screen can fade out
        drawEffects!.draw(effects: game.world.effects + additionalEffects, encoder: encoder, camera: playerCamera)

        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func loadTexture(name: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)

        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue),
            // use the linear color pixel format bgra8Unorm instead of SRGB
            // for now it's easier to work with and maybe just better?
            .SRGB: false
        ]

        return try! textureLoader.newTexture(name: name,
                                            scaleFactor: 1.0,
                                            bundle: nil,
                                            options: textureLoaderOptions)

    }
}
