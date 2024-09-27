//
//  KeyActionResolver.swift
//  Nerdle
//
//  Created by Andrii Zinoviev on 27.09.2024.
//

import AppKit
import Carbon

enum KeyActionResolver {
    enum Action {
        case `return`
        case moveLeft
        case moveRight
        case space
        case delete
        case character(Character)
    }
    
    static func resolveAction(event: NSEvent) -> Action? {
        if event.modifierFlags.contains(.command) ||
            event.modifierFlags.contains(.option) ||
            event.modifierFlags.contains(.control)
        {
            return nil
        }
        
        if event.keyCode == kVK_Return {
            return .return
        }
        
        if event.keyCode == kVK_LeftArrow {
            return .moveLeft
        }
        
        if event.keyCode == kVK_RightArrow {
            return .moveRight
        }
        
        if event.keyCode == kVK_Space {
            return .space
        }
        
        if event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete {
            return .delete
        }
        
        if let character = event.charactersIgnoringModifiers?.first {
            return .character(character)
        }
        
        return nil
    }
}
