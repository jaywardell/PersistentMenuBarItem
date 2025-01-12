//
//  ApplicationAccessoryModeManager.swift
//  PersistentMenuBarItems
//
//  Created by Joseph Wardell on 1/9/25.
//

import AppKit
import SwiftUI

@available(macOS 10.14, *)
@MainActor
fileprivate final class ApplicationAccessoryModeManager: Sendable {
    
    fileprivate var windowNumbers = Set<Int>()
    
    fileprivate static let shared = ApplicationAccessoryModeManager()
    private init() {}
    
    fileprivate func remember(_ windowNumber: Int) {
        Task {
            windowNumbers.insert(windowNumber)
        }
    }
    
    fileprivate func forget(_ windowNumber: Int) {
        Task {
            
            windowNumbers.remove(windowNumber)
            
            if windowNumbers.isEmpty {
                NSApplication.shared.enterAccessoryMode()
            }
        }
    }
        
    struct TrackedWindow: ViewModifier {
        @State private var windowNumber: Int?
        
        func body(content: Content) -> some View {
            content
                .onWindowIdentified { window in
                    windowNumber = window?.windowNumber
                    guard let windowNumber else { return }
                    ApplicationAccessoryModeManager.shared.remember(windowNumber)
                }
                .onDisappear {
                    guard let windowNumber else { return }
                    ApplicationAccessoryModeManager.shared.forget(windowNumber)
                }
        }
    }
}

// MARK: - Public

@available(macOS 10.15, *)
public extension EnvironmentValues {
    
    
    /// An environment value that provides a function that will
    /// bring the app back from accessory mode
    /// (if it's currently in accessory mode)
    /// and then bring the app to the foreground
    /// making it the frontmost app
    ///
    /// This function is often paired with a call to openWindow()
    /// So that a new window will be opened and the app brought to the foreground
    @Entry var bringBackFromBackground: () -> Void = {}
}

@available(macOS 10.15, *)
public extension View {

    /// add this modifer to any view to pass a bringBackFromBackground
    /// function down the view hierarchy to be available to child views.
    func canBringAppBackFromAccessoryMode() -> some View {
        self
            .environment(\.bringBackFromBackground, NSApplication.shared.bringBackFromAccessoryMode)
    }

    /// use this modifier to mark a view as one whose window will be tracked
    /// for the purposes of deciding when to send the app into accessory mode.
    ///
    /// When a window view marked with this modifier is closed,
    /// if there are no other windows with views marked with this modifier open,
    /// then the app will go into accessory mode,
    /// so it will not show up in the Dock or App Switcher
    /// and its menu bar will not be displayed.
    ///
    /// If the app provides a MenuBarView, then it will still be displayed
    /// in the menu bar status area
    ///
    /// The app will remain in this state
    /// until another window with a View marked with this modifier is opened
    func allowsAccessoryModeWhenDismissed() -> some View {
        self
            .modifier(ApplicationAccessoryModeManager.TrackedWindow())
    }
    
}
