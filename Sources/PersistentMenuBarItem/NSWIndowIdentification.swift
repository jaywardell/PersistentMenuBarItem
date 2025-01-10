//
//  NSWIndowIdentification.swift
//  PersistentMenuBarItems
//
//  based on code by Matthaus Woolard at https://gist.github.com/hishnash/c4ce28f749a87dd9502a30af34b1b266
//  Created by Joseph Wardell on 1/9/25.
//

import SwiftUI

fileprivate struct HostingWindowFinder: NSViewRepresentable {
    var callback: (NSWindow?) -> ()
    func makeNSView(context: Self.Context) -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

fileprivate struct MenuBarWindowIdentifier: ViewModifier {
        
    let callback: (NSWindow?) -> ()
    
    func body(content: Content) -> some View {
        content.background(
            HostingWindowFinder(callback: callback)
        )
    }
}

extension View {
    func onWindowIdentified(_ callback: @escaping (NSWindow?) -> Void) -> some View {
        modifier(MenuBarWindowIdentifier(callback: callback))
    }
}
