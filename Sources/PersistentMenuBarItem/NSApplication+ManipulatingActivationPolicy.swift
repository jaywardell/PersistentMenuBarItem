//
//  NSApplication+ManipulatingActivationPolicy.swift
//  PersistentMenuBarItems
//
//  Created by Joseph Wardell on 1/9/25.
//

import AppKit

extension NSApplication {
        
    func enterAccessoryMode() {
        setActivationPolicy(.accessory)
    }

    func bringBackFromAccessoryMode() {
        if activationPolicy() == .accessory {
            setActivationPolicy(.regular)
        }
        activate(ignoringOtherApps: true)
    }
}
