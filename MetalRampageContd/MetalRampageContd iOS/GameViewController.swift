//
//  GameViewController.swift
//  MetalRampageContd iOS
//
//  Created by David Kanenwisher on 3/5/22.
//

import UIKit
import MetalKit

// Our iOS specific view controller
class GameViewController: UIViewController {
    private let metalView = MTKView()
    private var renderer: Renderer!

    private let levels = loadLevels()
    private lazy var world = World(map: levels[0])

    private let maximumTimeStep: Float = 1 / 20 // cap at a minimum of 20 FPS
    private let worldTimeStep: Float = 1 / 120 // number of steps to take each frame
    private var lastFrameTime = CACurrentMediaTime()

    // variables for using the touch screen as a joystick
    private let panGesture = UIPanGestureRecognizer()
    private var inputVector: Float2 {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: view)
            var vector = Float2(x: Float(translation.x), y: Float(translation.y))
            vector /= max(joystickRadius, vector.length)

            //update the position of where the gesture started
            //to make movement a little smoother
            panGesture.setTranslation(CGPoint(
                x: Double(vector.x * joystickRadius),
                y: Double(vector.y * joystickRadius)
            ), in: view)

            return vector
        default:
            return Float2(x: 0, y: 0)
        }
    }
    // travel distance of 80 screen points ~0.5" so 40 radius
    private let joystickRadius: Float = 40

    // variables for using the touch screen as a fire button
    private let tapGesture = UITapGestureRecognizer()
    private var lastFiredTime: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalView()

        renderer = Renderer(metalView, width: 8, height: 8)

        // attach the pan gesture recognizer so there's an on screen joystick
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)

        // attach the UITapGestureRecognizer to turn the screen into a button
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(fire))
    }

    func setupMetalView() {
        view.addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        metalView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        metalView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        metalView.contentMode = .scaleAspectFit
        metalView.backgroundColor = .black
        metalView.delegate = self
    }
}

// Methods for turning the screen into a fire button
extension GameViewController {
    @objc func fire(_ gestureRecognizer: UITapGestureRecognizer) {
        lastFiredTime = CACurrentMediaTime()
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
            // pressing fire happens while rendering new frames so the press we care about is the one that happened after
            // the last frame was rendered.
            isFiring: lastFiredTime > lastFrameTime,
            showMap: false,
            drawWorld: truew
        )
        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            if let action = world.update(timeStep: Float(timeStep /  worldSteps), input: input) {
                switch action {
                case .loadLevel(let index):
                    let index = index % levels.count
                    world.setLevel(levels[index])
                    // quick work around to make sure aspect is passed when a new renderer is created
                    renderer = Renderer(metalView, width: 8, height: 8).also {
                        $0.updateAspect(renderer.aspect)
                    }
                }
            }
        }
        lastFrameTime = time

        renderer.render(world)
    }
}

extension GameViewController: UIGestureRecognizerDelegate {

    // Allow for more than on gesture recognizer to do its thing at the same time.
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
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
