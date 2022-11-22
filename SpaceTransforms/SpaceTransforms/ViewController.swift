//
//  ViewController.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    private let metalView = MTKView()

    private let maximumTimeStep: Float = 1 / 20 // cap at a minimum of 20 FPS
    private let worldTimeStep: Float = 1 / 120 // number of steps to take each frame
    private var lastFrameTime = CACurrentMediaTime()

    private var viewWidth: Float = 0
    private var viewHeight: Float = 0

    private var game = Game()

    private var renderer: Renderer!

    // Keyboard input handling
    private var keyDownHandler: Any?
    private var keyUpHandler: Any?
    private var moveForward = false
    private var moveBackward = false
    private var moveLeft = false
    private var moveRight = false

    private var inputVector: Float2 {
        var vector = Float2()
        let rate: Float = 0.005
        if moveForward {
            vector += Float2(0, rate)
        }
        if moveBackward {
            vector += Float2(0, -1 * rate)
        }
        if moveLeft {
            vector += Float2(-1 * rate, 0)
        }
        if moveRight {
            vector += Float2(rate, 0)
        }

        return vector
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalView()
        enableInputMonitors()

        renderer = Renderer(metalView, width: 8, height: 8)
    }

    override func viewDidDisappear() {
        disableInputMonitors()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func setupMetalView() {
        view.addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        metalView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        metalView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        metalView.delegate = self
    }
}

extension ViewController: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        print("size height: \(size.height) width: \(size.width)")
        print("frame height: \(view.frame.height) width: \(view.frame.width)")

        viewWidth = Float(view.frame.width)
        viewHeight = Float(view.frame.height)
        renderer.updateAspect(width: Float(size.width), height: Float(size.height))
    }

    public func draw(in view: MTKView) {
        // increase accuracy of collisions by reducing time between updates
        // also avoid spiralling when world updates take longer than frame step
        let time = CACurrentMediaTime()
        let timeStep = min(maximumTimeStep, Float(CACurrentMediaTime() - lastFrameTime))

        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        let input = Input(movement: inputVector)
        for _ in 0 ..< Int(worldSteps) {
            game.update(timeStep: timeStep / worldSteps, input: input)
        }
        lastFrameTime = time

        renderer.render(game)
    }
}

extension ViewController {
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
            moveLeft = true
        case "d":
            print(event.characters!)
            moveRight = true
        case "x":
            print(event.characters!)
        case "c":
            print(event.characters!)
        case "m":
            print(event.characters!)
        case "W":
            print(event.characters!)
        case "S":
            print(event.characters!)
        case " ":
            print("space!")
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
            moveLeft = false
        case "d":
            print(event.characters!)
            moveRight = false
        case "W":
            print(event.characters!)
        case "S":
            print(event.characters!)
        default:
            return
        }
    }

    private func disableInputMonitors() {
        guard let keyDownHandler = keyDownHandler else { return }
        NSEvent.removeMonitor(keyDownHandler)

        guard let keyUpHandler = keyUpHandler else { return }
        NSEvent.removeMonitor(keyUpHandler)
    }
}
