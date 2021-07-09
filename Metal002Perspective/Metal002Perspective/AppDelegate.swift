//
//  AppDelegate.swift
//  Metal002Perspective
//
//  Created by David Kanenwisher on 7/8/21.
//

import Cocoa
import MetalKit

@main
class Application: NSObject {

    private struct MetalBits {
        let device: MTLDevice
        let pipelines: [String: MTLRenderPipelineState]
        let vertices: [String: Vertices]
    }
}

extension Application: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

