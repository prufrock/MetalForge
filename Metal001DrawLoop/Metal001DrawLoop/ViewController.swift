//
//  ViewController.swift
//  Metal001DrawLoop
//
//  Created by David Kanenwisher on 7/5/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? MTKView else {
            fatalError("Metal view not setup in storyboard.")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

