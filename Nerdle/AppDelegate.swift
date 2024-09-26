//
//  AppDelegate.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainWindow: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let viewController = ViewController()
        let window = NSWindow(contentViewController: viewController)
        
        window.makeKeyAndOrderFront(nil)
        window.center()
        
        self.mainWindow = window
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
