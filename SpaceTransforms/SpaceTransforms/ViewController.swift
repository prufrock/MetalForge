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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalView()

        renderer = Renderer(metalView, width: 8, height: 8)
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
        for _ in 0 ..< Int(worldSteps) {
            game.update(timeStep: timeStep / worldSteps)
        }
        lastFrameTime = time

        renderer.render(game)
    }
}
