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
    private var renderer: Renderer!

    private var keyDownHandler: Any?
    private var keyUpHandler: Any?

    private var moveForward = false
    private var moveBackward = false
    private var turnLeft = false
    private var turnRight = false
    private var showMap = false
    private var drawWorld = true

    private let levels = loadLevels()
    private lazy var world = World(map: levels[0])

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
        setupMetalView()

        renderer = Renderer(metalView, width: 8, height: 8)
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
        let rotation = inputVector.x * world.player.turningSpeed * worldTimeStep
        let input = Input(
            speed: -inputVector.y,
            rotation: Float2x2.rotate(rotation),
            rotation3d: Float4x4.rotateY(inputVector.x * world.player.turningSpeed * worldTimeStep),
            // Holding off on implementing this for tvOS
            isFiring: false,
            showMap: showMap,
            drawWorld: drawWorld
        )
        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            if let action = world.update(timeStep: Float(timeStep /  worldSteps), input: input) {
                switch action {
                case .loadLevel(let index):
                    let index = index % levels.count
                    world.setLevel(levels[index])
                    //TODO look for a way to create a new renderer when a new World is created
                    renderer = Renderer(metalView, width: 8, height: 8)
                }
            }
        }
        lastFrameTime = time

        renderer.render(world)
    }
}


/**
 Loads levels from Levels.json and creating a Tilemap for each level and returning the array of Tilemaps.
 - Returns: [Tilemap]
 */
private func loadLevels() -> [Tilemap] {
    let jsonUrl = Bundle.main.url(forResource: "Levels", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonUrl)
    let levels = try! JSONDecoder().decode([MapData].self, from: jsonData)
    return levels.enumerated().map { Tilemap($0.element, index: $0.offset) }
}

