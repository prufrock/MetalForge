//
//  ViewController.swift
//  Metal009Rampage03macOS
//
//  Created by David Kanenwisher on 1/21/22.
//

import Cocoa
import MetalKit

class GameViewController: NSViewController {
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

    private var world = World(map: loadMap())
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
    // travel distance of 80 screen points ~0.5" so 40 radius
    private let joystickRadius: Float = 40

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalView()
        enableInputMonitors()

        renderer = Renderer(metalView, width: 8, height: 8)
    }

    override func viewDidDisappear() {
        disableInputMonitors()
    }

    private func enableInputMonitors() {
        //return nil to turn off beep
        keyDownHandler = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [unowned self] in
            self.keyDown(with: $0)
            return nil
        }

        keyUpHandler = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [unowned self] in
            self.keyUp(with: $0)
            return nil
        }
    }

    override func keyDown(with event: NSEvent) {
        switch event.characters {
        case "w":
            print(event.characters!)
            moveForward = true
        case "s":
            print(event.characters!)
            moveBackward = true
        case "a":
            print(event.characters!)
            turnLeft = true
        case "d":
            print(event.characters!)
            turnRight = true
        case "x":
            print(event.characters!)
            drawWorld.toggle()
        case "c":
            print(event.characters!)
        case "m":
            print(event.characters!)
            showMap.toggle()
        case "W":
            print(event.characters!)
        case "S":
            print(event.characters!)
        default:
            return
        }
    }

    override func keyUp(with event: NSEvent) {
        switch event.characters {
        case "w":
            print(event.characters!)
            moveForward = false
        case "s":
            print(event.characters!)
            moveBackward = false
        case "a":
            print(event.characters!)
            turnLeft = false
        case "d":
            print(event.characters!)
            turnRight = false
        case "W":
            print(event.characters!)
        case "S":
            print(event.characters!)
        default:
            return
        }
    }

    private func disableInputMonitors() {
        guard let keyDownHandler = self.keyDownHandler else { return }
        NSEvent.removeMonitor(keyDownHandler)

        guard let keyUpHandler = self.keyUpHandler else { return }
        NSEvent.removeMonitor(keyUpHandler)
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
            rotation: Float2x2(rotate: rotation),
            rotation3d: Float4x4(rotateY: inputVector.x * world.player.turningSpeed * worldTimeStep),
            showMap: showMap,
            drawWorld: drawWorld
        )
        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            world.update(timeStep: Float(timeStep /  worldSteps), input: input)
        }
        lastFrameTime = time

        renderer.render(world)
    }
}


private func loadMap() -> Tilemap {
    let jsonUrl = Bundle.main.url(forResource: "Map", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonUrl)
    return try! JSONDecoder().decode(Tilemap.self, from: jsonData)
}
