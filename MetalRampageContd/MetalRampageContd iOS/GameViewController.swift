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
    private var renderer: RNDRRenderer!
    private var audioEngine = AudioEngine()

    private let levels = loadLevels()
    private lazy var world = GMWorld(map: levels[0])

    private var game = GMGame(levels: loadLevels(), font: loadFont())

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
        audioEngine.setUpAudio()
        setupMetalView()

        renderer = RNDRRenderer(metalView, width: 8, height: 8)

        // attach the pan gesture recognizer so there's an on screen joystick
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)

        // attach the UITapGestureRecognizer to turn the screen into a button
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(fire))

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
        let rotation = inputVector.x * game.world.player.turningSpeed * worldTimeStep
        var input = GMInput(
            speed: -inputVector.y,
            rotation: Float2x2.rotate(rotation),
            rotation3d: Float4x4.rotateY(inputVector.x * game.world.player.turningSpeed * worldTimeStep),
            // pressing fire happens while rendering new frames so the press we care about is the one that happened after
            // the last frame was rendered.
            isFiring: lastFiredTime > lastFrameTime,
            showMap: false,
            drawWorld: true
        )

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
