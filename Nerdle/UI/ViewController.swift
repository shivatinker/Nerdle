//
//  ViewController.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

import AppKit

class ViewController: NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.preferredContentSize = .init(width: 480, height: 350)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView()
    }
}
