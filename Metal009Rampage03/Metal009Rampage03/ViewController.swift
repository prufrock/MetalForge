//
//  ViewController.swift
//  Metal009Rampage03
//
//  Created by David Kanenwisher on 12/29/21.
//

import UIKit
import MetalKit
import Engine

class ViewController: UIViewController {
    private let metalView = MTKView()
    private var renderer: Renderer!

    private var world = World(map: loadMap())
    private let maximumTimeStep: Float = 1 / 20 // cap at a minimum of 20 FPS
    private let worldTimeStep: Float = 1 / 120 // number of steps to take each frame
    private var lastFrameTime = CACurrentMediaTime()
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
        metalView.contentMode = .scaleAspectFit
        metalView.backgroundColor = .black
        metalView.delegate = self
        metalView.addGestureRecognizer(panGesture)
    }
}

extension ViewController: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        print("height: \(size.height) width: \(size.width)")
        print("height: \(view.frame.height) width: \(view.frame.width)")

        renderer.aspect = Float(size.width / size.height)
    }

    public func draw(in view: MTKView) {
        // increase accuracy of collisions by reducing time between updates
        // also avoid spiralling when world updates take longer than frame step
        let time = CACurrentMediaTime()
        let timeStep = min(maximumTimeStep, Float(CACurrentMediaTime() - lastFrameTime))
        let input = Input(velocity: inputVector)
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
