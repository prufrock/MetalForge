//
//  ViewController.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    private var state: ControllerStates = .notDrawing

    private var drawer: MTKViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        startDrawing()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidDisappear() {
        state = .notDrawing
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

        drawer = Drawer(
            metalBits: MetalBits.create(view: view),
            world: GameWorld(
                node: GameWorld.Node(
                    location: VerticeCollection().c[.originPoint]!.vertices[0],
                    vertices: VerticeCollection().c[.cube]!)
            )
        )

        state = .drawing
        print(state)
    }

    private func printState() {
        print(#function + " \(state)")
    }

    private enum ControllerStates {
        case notDrawing
        case drawing
    }
}

