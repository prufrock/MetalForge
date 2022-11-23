//
//  ViewController.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    lazy var window: NSWindow = self.view.window!
    private let metalView = MTKView()

    private let maximumTimeStep: Float = 1 / 20 // cap at a minimum of 20 FPS
    private let worldTimeStep: Float = 1 / 120 // number of steps to take each frame
    private var lastFrameTime = CACurrentMediaTime()

    private var viewWidth: Float = 0
    private var viewHeight: Float = 0

    private var game = Game(levels: loadLevels())

    private var renderer: Renderer!

    // Keyboard input handling
    private var keyDownHandler: Any?
    private var keyUpHandler: Any?
    private var moveForward = false
    private var moveBackward = false
    private var moveLeft = false
    private var moveRight = false
    private var moveCameraUp = false
    private var moveCameraDown = false
    private var moveCameraLeft = false
    private var moveCameraRight = false
    private var camera: AvailableCameras = .overhead

    // Mouse input handling
    // The last time the screen was clicked.
    // Needed so that the mouseLocation isn't constantly sent in as input
    private var lastClickedTime: Double = 0.0
    var mouseLocation: NSPoint { window.convertPoint(fromScreen: NSEvent.mouseLocation) }

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

    private var cameraInputVector: Float3 {
        var vector = Float3()
        let rate: Float = 0.005
        if moveCameraUp {
            vector += Float3(0, rate, 0)
        }
        if moveCameraDown {
            vector += Float3(0, -1 * rate, 0)
        }
        if moveCameraLeft {
            vector += Float3(-1 * rate, 0, 0)
        }
        if moveCameraRight {
            vector += Float3(rate, 0, 0)
        }

        return vector
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalView()
        enableInputMonitors()

        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) {
            print("mouseLocation:", String(format: "%.1f, %.1f", self.mouseLocation.x, self.mouseLocation.y))
            self.lastClickedTime = CACurrentMediaTime()

            return $0
        }

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

        let isClicked = lastClickedTime > lastFrameTime

        let input = Input(
            movement: inputVector,
            cameraMovement: cameraInputVector,
            camera: camera,
            isClicked: isClicked,
            clickCoordinates: MFloat2(space: .screen, value: mouseLocation.f2)
        )
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
    // KeyCodes https://gist.github.com/swillits/df648e87016772c7f7e5dbed2b345066
        switch event.keyCode {
        case 0x0D: // w
            print(event.characters!)
            moveForward = true
        case 0x01: // s
            print(event.characters!)
            moveBackward = true
        case 0x00: // a
            print(event.characters!)
            moveLeft = true
        case 0x02: // d
            print(event.characters!)
            moveRight = true
        case 18: // 1
            camera = .overhead
        case 19: // 2
            camera = .floatingCamera
        case 0x7E:
            print("up arrow")
        case 0x7D:
            print("down arrow")
        case 0x7B:
            print("left arrow")
        case 0x7C:
            print("right arrow")
        case 0x53:
            print("numpad 1")
        case 0x54, 0x2D:
            print("numpad 2 or n")
            moveCameraDown = true
        case 0x55:
            print("numpad 3")
        case 0x56, 0x4:
            print("numpad 4 or h")
            moveCameraLeft = true
        case 0x57:
            print("numpad 5")
        case 0x58, 0x26:
            print("numpad 6 or j")
            moveCameraRight = true
        case 0x59:
            print("numpad 7")
        case 0x5B, 0x20:
            print("numpad 8 or u")
            moveCameraUp = true
        case 0x5C:
            print("numpad 9")
        default:
            print(event.keyCode)
        }
    }

    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 0x0D: // w
            print(event.characters!)
            moveForward = false
        case 0x01: // s
            print(event.characters!)
            moveBackward = false
        case 0x00: // a
            print(event.characters!)
            moveLeft = false
        case 0x02: // d
            print(event.characters!)
            moveRight = false
        case 18: // 1
            break;
        case 19: // 2
            break;
        case 0x7E: // up arrow
            break
        case 0x7D: // down arrow
            break
        case 0x7B: // left arrow
            break
        case 0x7C: // right arrow
            break
        case 0x53: // numpad 1
            break
        case 0x54, 0x2D: // numpad 2
            moveCameraDown = false
        case 0x55: // numpad 3
            break
        case 0x56, 0x4: // numpad 4
            moveCameraLeft = false
        case 0x57: // numpad 5
            break
        case 0x58, 0x26: // numpad 6
            moveCameraRight = false
        case 0x59: // numpad 7
            break
        case 0x5B, 0x20: // numpad 8
            moveCameraUp = false
            break
        case 0x5C: // numpad 9
            break
        default:
            print(event.keyCode)
        }
    }

    private func disableInputMonitors() {
        guard let keyDownHandler = keyDownHandler else { return }
        NSEvent.removeMonitor(keyDownHandler)

        guard let keyUpHandler = keyUpHandler else { return }
        NSEvent.removeMonitor(keyUpHandler)
    }
}

/**
Loads levels from Levels.json and creating a Tilemap for each level and returning the array of Tilemaps.
- Returns: [Tilemap]
*/
private func loadLevels() -> [TileMap] {
    let jsonUrl = Bundle.main.url(forResource: "Levels", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonUrl)
    let levels = try! JSONDecoder().decode([MapData].self, from: jsonData)
    return levels.enumerated().map { index, mapData in
        // The MapGenerator is going to generate the maps so it's taking over.
        TileMap(mapData, index: index)
    }
}

extension NSPoint {
    var f2: Float2 {
        get {
            Float2(Float(x), Float(y))
        }
    }
}
