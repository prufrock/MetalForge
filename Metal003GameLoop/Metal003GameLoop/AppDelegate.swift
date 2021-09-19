//
//  AppDelegate.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let viewController = NSApplication.shared.windows.first!.contentViewController as! ViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
