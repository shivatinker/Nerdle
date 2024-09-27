//
//  KeyInterceptorView.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

import AppKit
import SwiftUI

extension View {
    func handleKeys(action: @escaping (NSEvent) -> Void) -> some View {
        self.background(
            KeyInterceptor(action: action)
        )
    }
}

private struct KeyInterceptor: NSViewRepresentable {
    let action: (NSEvent) -> Void
    
    func makeNSView(context: Context) -> KeyInterceptorView {
        KeyInterceptorView(action: self.action)
    }
    
    func updateNSView(_ nsView: KeyInterceptorView, context: Context) {}
}

private final class KeyInterceptorView: NSView {
    let action: (NSEvent) -> Void
    
    init(action: @escaping (NSEvent) -> Void) {
        self.action = action
        
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var acceptsFirstResponder: Bool {
        true
    }
    
    override func keyDown(with event: NSEvent) {
        self.action(event)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.window?.makeFirstResponder(self)
    }
}
