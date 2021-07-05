//
//  ViewController.swift
//  Metal001DrawLoop
//
//  Created by David Kanenwisher on 7/5/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    /**
     * Have to make sure you assign the MTKView delegate to a variables otherwise `draw()` can't be called on it. I
     * think it's because it goes out of scope after viewDidLoad() is called. So it gets setup all the way and then
     * disappears. I wonder how it works that a delegate object can disappear but not cause the application to explode.
     * There must ge a guard that checks the delegate and just returns when nothing is there.
     */
    var drawer: MTKViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? MTKView else {
            fatalError("Metal view not setup in storyboard.")
        }

        drawer = Drawer(view: view)
    }
}

