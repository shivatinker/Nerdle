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
        
        window.titleVisibility = .hidden
        window.styleMask = [
            .closable,
            .fullSizeContentView,
            .titled,
        ]
        window.titlebarAppearsTransparent = true
        window.makeKeyAndOrderFront(nil)
        
        window.setFrameAutosaveName("Main Window")
        window.setFrameUsingName("Main Window")
        
        window.isMovableByWindowBackground = true
        
        self.mainWindow = window
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
