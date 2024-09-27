//
//  ViewController.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

import AppKit
import SwiftUI

class ViewController: NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSHostingView(rootView: Grid())
    }
}
