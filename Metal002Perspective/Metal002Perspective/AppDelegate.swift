//
//  AppDelegate.swift
//  Metal002Perspective
//
//  Created by David Kanenwisher on 7/8/21.
//

import Cocoa
import MetalKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var metalBits: AppDelegate.MetalBits?

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

    private struct MetalBits {
        let device: MTLDevice
        let pipelines: [String: MTLRenderPipelineState]
        let vertices: [String: Vertices]
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print(#function)
        print("""
              Let's get things started!🎊
              """)

        let viewController = NSApplication.shared.windows.first!.contentViewController as! ViewController

        setupMetalBits()

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
}
