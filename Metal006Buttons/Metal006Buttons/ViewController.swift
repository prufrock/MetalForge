//
//  ViewController.swift
//  Metal006Buttons
//
//  Created by David Kanenwisher on 11/10/21.
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
            world: GMCreateScene()
        )

        state = .drawing
        print(state)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)

        drawer!.click(x: Float(location.x), y: Float(location.y))
    }

    private func printState() {
        print(#function + " \(state)")
    }

    private enum ControllerStates {
        case notDrawing
        case drawing
    }

}

