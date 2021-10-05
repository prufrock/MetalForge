//
//  ViewController.swift
//  Metal005SceneGraph
//
//  Created by David Kanenwisher on 10/5/21.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    private var state: ControllerStates = .notDrawing

    private var drawer: Renderer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        startDrawing()
    }

    private func startDrawing() {
        guard state != .drawing else {
            print(#function + " called while already drawing. Did the view get reloaded somehow?")
            return
        }

        guard let view = self.view as? MTKView else {
            fatalError("""
                       Metal view not setup in storyboard. It's too horrible to continue. Shutting it DOWN!
                       """)
        }

        drawer = Renderer(
            metalBits: MetalBits.create(view: view),
            world: GameWorld(nodes: [], cameraDimensions: (Float(1.0), Float(1.0)))
        )

        state = .drawing
        print(state)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)

        drawer!.click()

        print("x: \(location.x) y: \(location.y)")
    }

    private func printState() {
        print(#function + " \(state)")
    }

    private enum ControllerStates {
        case notDrawing
        case drawing
    }

}

