//
//  AppDelegate.swift
//  Metal001DrawLoop
//
//  Created by David Kanenwisher on 7/5/21.
//

import Cocoa
import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // Need a place to put the Metal bits once they are ready and to access them when needed.
    private var metalBits: MetalBits?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print(#function)
        print("""
              Let's get things started!🎊
              """)


        // I think this is the best way to get a hold of the first window shown.
        // https://stackoverflow.com/questions/40008141/nsapplicationdelegate-not-working-without-storyboard/41029060
        let viewController = NSApplication.shared.windows.first!.contentViewController as! ViewController

        // Pass the Drawer.Builder into the view controller. This is to allow the Drawer to be initialized with all of
        // the bits it needs to run that could be shared across many "Drawers": MTLDevice, MTLLibrary, MTLPipelines,
        // models, etc. It's also helpful to delay attaching to the MTLView as the view delegate. The moment that
        // happens drawing starts and everything needs to be ready for that.
        viewController.setup(drawerBuilder: configureDrawerBuilder())
        viewController.startDrawing()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print(#function)
        print("""
              Time to close up the shop and head home...
              """)
    }

    // Let's get all the Metal stuff ready.
    private func setupMetalBits() {
        // Put in something simple to get started with.
        let singlePoint = Vertices(Point(0.5, 0.2, 0.0))

        metalBits = MetalBits(
                device: MTLCreateSystemDefaultDevice()!,
                pipelines: [:],
                libraries: [:],
                vertices: ["SinglePoint": singlePoint]
        )
    }

    private func configureDrawerBuilder() -> Drawer.Builder {
        Drawer.Builder()
    }

    // All the stuff that could potentially be shared(I think).
    private struct MetalBits {
        let device: MTLDevice
        let pipelines: [String: MTLRenderPipelineState]
        let libraries: [String: MTLLibrary]
        let vertices: [String: Vertices]
    }
}

