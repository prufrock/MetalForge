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

        let vertices = VerticeCollection().c[.originPoint]!
        drawer = Drawer(
            metalBits: MetalBits.create(view: view),
            vertices: VerticeCollection().c[.singlePoint]!,
            world: GameWorld(
                vertices: VerticeCollection().c[.originPoint]!,
                node: GameWorld.Node(
                    location: vertices.vertices[0],
                    vertices: vertices)
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

