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
    private var metalBits: AppDelegate.MetalBits?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print(#function)
        print("""
              Let's get things started!🎊
              """)


        // I think this is the best way to get a hold of the first window shown.
        // https://stackoverflow.com/questions/40008141/nsapplicationdelegate-not-working-without-storyboard/41029060
        let viewController = NSApplication.shared.windows.first!.contentViewController as! ViewController

        // Do all of the work to get Metal ready.
        setupMetalBits()

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
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("""
                       I looked in the computer and didn't find a device...sorry =/
                       """)
        }

        guard let library = device.makeDefaultLibrary() else {
            fatalError("""
                       What in the what?! The library couldn't be loaded.
                       """)
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let defaultPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        // Put in something simple to get started with.
        let singlePoint = Vertices(Point(0.5, 0.2, 0.0))

        let square = Vertices(
                Point(0.2, 0.2, 0.0),
                Point(-0.2, 0.2, 0.0),
                Point(-0.2, 0.2, 0.0),
                Point(-0.2, -0.2, 0.0),
                Point(-0.2, -0.2, 0.0),
                Point(0.2, -0.2, 0.0),
                Point(0.2, -0.2, 0.0),
                Point(0.2, 0.2, 0.0),
                primitiveType: .line
        )

        metalBits = MetalBits(
                device: MTLCreateSystemDefaultDevice()!,
                pipelines: ["Default": defaultPipelineState],
                libraries: ["Default": library],
                vertices: [
                    "SinglePoint": singlePoint,
                    "Square": square
                ]
        )
    }

    private func configureDrawerBuilder() -> Drawer.Builder {
        let builder = Drawer.Builder()

        guard let metalBits = metalBits else {
            fatalError(
                    """
                    Oh noes! You forgot to setup metalBits!
                    """
            )
        }

        builder.device = metalBits.device
        builder.pipeline = metalBits.pipelines["Default"]
        builder.vertices = metalBits.vertices["Square"]

        return builder
    }

    // All the stuff that could potentially be shared(I think).
    private struct MetalBits {
        let device: MTLDevice
        let pipelines: [String: MTLRenderPipelineState]
        // I ended up not need the libraries for now because they are in the pipeline state.
        let libraries: [String: MTLLibrary]
        let vertices: [String: Vertices]
    }
}

