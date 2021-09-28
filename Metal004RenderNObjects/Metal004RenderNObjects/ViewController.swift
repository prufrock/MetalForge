//
//  ViewController.swift
//  Metal004RenderNObjects
//
//  Created by David Kanenwisher on 9/27/21.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    private var state: ControllerStates = .notDrawing

    private var drawer: Drawer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

