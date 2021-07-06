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

    /**
     * I want to be able to initialize the pipeline state objects and shaders before the ViewController runs. Although
     * I'm currently only planning this to be a one window app so maybe that's overkill. I suspect it may be a somewhat
     * useful piece of knowledge to have in the future. Thus, I went one level up and plan to initialize the required
     * objects at that level. I suspect it may be helpful to figure out how to have an initial view controller that
     * loads the app and then opens the first window that should be open for the app. I don't know how to do fancy stuff
     * like that yet so I am going to stay away from it and use the builder here instead.
     */
    var drawerBuilder: Drawer.Builder?

    override func viewDidLoad() {
        super.viewDidLoad()
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
}

