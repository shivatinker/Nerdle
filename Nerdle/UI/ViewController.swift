//
//  ViewController.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 26.09.2024.
//

import AppKit
import NerdleKit
import SwiftUI

class ViewController: NSViewController {
    private let settingsController = SettingsController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let model = try! self.makeViewModel()
        
        let container = NSView()
        let view = NSHostingView(rootView: GameView(model: model))
        
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        let router = RootRouter(viewController: self)
        
        let titleBar = NSHostingView(
            rootView: TitleBar(
                router: router,
                model: model
            )
        )
        
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleBar)
        
        NSLayoutConstraint.activate([
            titleBar.topAnchor.constraint(equalTo: container.topAnchor),
            titleBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 48),
            
            view.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        self.view = container
    }
    
    func showSettings() {
        let window = NSWindow()
        window.styleMask = [.closable, .titled]
        window.titlebarAppearsTransparent = true
        
        let bridge = ModalWindowBridge(window: window)
        
        window.contentViewController = NSHostingController(
            rootView: SettingsView(
                modalBridge: bridge,
                controller: self.settingsController
            )
        )
        
        self.view.window?.beginSheet(window)
    }
    
    private func makeViewModel() throws -> GameViewModel {
        let path = self.dbPath
        
        print("DB Path: \(path ?? "<nil>")")
        
        return try GameViewModel(
            databaseController: DatabaseController(path: path),
            settingsController: self.settingsController
        )
    }
    
    private var dbPath: String? {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Failed to find application support directory!")
            return nil
        }
        
        return url.appending(component: "nerdle.db").path(percentEncoded: false)
    }
}

@MainActor
private final class RootRouter {
    private unowned let viewController: ViewController
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func showSettings() {
        self.viewController.showSettings()
    }
}

final class ModalWindowBridge {
    unowned let window: NSWindow
    
    init(window: NSWindow) {
        self.window = window
    }
}

private struct TitleBar: View {
    let router: RootRouter
    @StateObject var model: GameViewModel
    
    var body: some View {
        ZStack {
            Text("Nerdle")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: UnitPoint(x: 0, y: 1),
                        endPoint: UnitPoint(x: 1, y: 1)
                    )
                )
                .font(.system(size: 24, weight: .semibold))
            
            HStack {
                Spacer()
                
                if self.model.isNewGameEnabled {
                    ToolbarButton(
                        imageName: "plus",
                        action: self.model.startNewGame
                    )
                }
                
                ToolbarButton(
                    imageName: "gearshape.fill",
                    action: self.router.showSettings
                )
                
                ToolbarButton(
                    imageName: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                    action: {
                        self.model.isHistoryVisible.toggle()
                    }
                )
            }
            .padding(.trailing, 16)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }
}

private struct ToolbarButton: View {
    @State var isHovered = false
    
    let imageName: String
    let action: () -> Void
    
    var body: some View {
        Image(systemName: self.imageName)
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(self.isHovered ? Color.white.opacity(0.05) : .clear)
            )
            .onHover {
                self.isHovered = $0
            }
            .onTapGesture(perform: self.action)
    }
}
