//
//  GameViewController.swift
//  MetalRampageContd tvOS
//
//  Created by David Kanenwisher on 3/5/22.
//

import UIKit
import MetalKit

// Our tvOS specific view controller
class GameViewController: UIViewController {
    private let metalView = MTKView()
    private var renderer: RNDRRenderer!
    private var audioEngine = AudioEngine()

    private let gameControllerManager = GameControllerManager()
    private var keyDownHandler: Any?
    private var keyUpHandler: Any?

    private var moveForward = false
    private var moveBackward = false
    private var turnLeft = false
    private var turnRight = false
    private var showMap = false
    private var drawWorld = true

    private let levels = loadLevels()
    private lazy var world = GMWorld(map: levels[0])

    private var game = GMGame(levels: loadLevels(), font: loadFont())

    private let maximumTimeStep: Float = 1 / 20 // cap at a minimum of 20 FPS
    private let worldTimeStep: Float = 1 / 120 // number of steps to take each frame
    private var lastFrameTime = CACurrentMediaTime()
    private var inputVector: Float2 {
        var vector = Float2()
        let rate: Float = 0.5
        if moveForward {
            vector += Float2(0, -1 * rate)
        }
        if moveBackward {
            vector += Float2(0, rate)
        }
        if turnLeft {
            vector += Float2(-1 * rate, 0)
        }
        if turnRight {
            vector += Float2(rate, 0)
        }

        return vector
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine.setUpAudio()
        setupMetalView()

        renderer = RNDRRenderer(metalView, width: 8, height: 8)

        // Make it so Game can call on delegate methods
        game.delegate = self
    }

    func setupMetalView() {
        view.addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        metalView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        metalView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        metalView.delegate = self
    }
}

extension GameViewController: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        print("height: \(size.height) width: \(size.width)")
        print("height: \(view.frame.height) width: \(view.frame.width)")

        renderer.updateAspect(width: Float(size.width), height: Float(size.height))
    }

    public func draw(in view: MTKView) {
        // increase accuracy of collisions by reducing time between updates
        // also avoid spiralling when world updates take longer than frame step
        let time = CACurrentMediaTime()
        let timeStep = min(maximumTimeStep, Float(CACurrentMediaTime() - lastFrameTime))
        let inputVector = self.inputVector
        let rotation = inputVector.x * game.world.player.turningSpeed * worldTimeStep
        var input = GMInput(
            speed: -inputVector.y,
            rotation: Float2x2.rotate(rotation),
            rotation3d: Float4x4.rotateY(inputVector.x * game.world.player.turningSpeed * worldTimeStep),
            // Holding off on implementing this for tvOS
            isFiring: false,
            showMap: showMap,
            drawWorld: drawWorld,
            isTouching: false
        )
        if let controllerInput = gameControllerManager.input(turningSpeed: game.world.player.turningSpeed, worldTimeStep: worldTimeStep) {
            input.speed = controllerInput.speed
            input.rotation = controllerInput.rotation
            input.rotation3d = controllerInput.rotation3d
            input.isFiring = controllerInput.isFiring
        }


        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            game.update(timeStep: timeStep / worldSteps, input: input)
            // the world advances faster than draw calls are made so to ensure "isFiring is only applied once it gets set to false. Especailly helpful when going from the title screen into the game.
            input.isFiring = false
        }
        lastFrameTime = time

        renderer.render(game)
    }
}


/**
 Loads levels from Levels.json and creating a Tilemap for each level and returning the array of Tilemaps.
 - Returns: [Tilemap]
 */
private func loadLevels() -> [GMTilemap] {
    let jsonUrl = Bundle.main.url(forResource: "Levels", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonUrl)
    let levels = try! JSONDecoder().decode([GMMapData].self, from: jsonData)
    return levels.enumerated().map { index, mapData in
        // The MapGenerator is going to generate the maps so it's taking over.
        GMMapGenerator(mapData: mapData, index: index).map
    }}

private func loadFont() -> GMFont {
    let jsonUrl = Bundle.main.url(forResource: "Font", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonUrl)
    return try! JSONDecoder().decode(GMFont.self, from: jsonData)
}

extension GameViewController: GMGameDelegate {
    func playSound(_ sound: Sound) {
        audioEngine.play([sound])
    }

    func clearSounds() {
        audioEngine.clearSounds()
    }

    func updateRenderer(_ world: GMWorld) {
        renderer = RNDRRenderer(metalView, width: 8, height: 8).also {
            $0.updateAspect(renderer.aspect)
        }
    }
}
