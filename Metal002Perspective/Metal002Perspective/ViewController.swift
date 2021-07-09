//
//  ViewController.swift
//  Metal002Perspective
//
//  Created by David Kanenwisher on 7/8/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    var drawer: MTKViewDelegate?

    var drawerBuilder: Drawer.Builder?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setup(drawerBuilder: Drawer.Builder) {
        guard let view = self.view as? MTKView else {
            fatalError("""
                       Metal view not setup in storyboard. It's too horrible to continue. Shutting it DOWN!
                       """)
        }

        drawerBuilder.view = view

        self.drawerBuilder = drawerBuilder
    }

    func startDrawing() {
        guard let drawerBuilder = drawerBuilder else {
            fatalError("""
                       Oh no! You called start drawing before you passed me a drawer builder. Get out now! POOM!💥
                       """)
        }

        drawer = drawerBuilder.build()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

