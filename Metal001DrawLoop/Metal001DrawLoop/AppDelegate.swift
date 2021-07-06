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
        // I think this is the best way to get a hold of the first window shown.
        // https://stackoverflow.com/questions/40008141/nsapplicationdelegate-not-working-without-storyboard/41029060
        let viewController = NSApplication.shared.windows.first!.contentViewController as! ViewController
        viewController.setup(drawerBuilder: Drawer.Builder())
        viewController.startDrawing()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

