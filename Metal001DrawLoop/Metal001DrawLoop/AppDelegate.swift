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
        viewController.setup(drawerBuilder: Drawer.Builder())
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

