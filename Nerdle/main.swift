//
//  main.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
