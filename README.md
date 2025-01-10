#  PeristentMenuBarItem

It's a pretty common thing letely for an app to show a Menu Bar Extra so that the user can quickly get back to your app when they're doing something else.

But some apps are upping the game by automatically moving themselves to the background if they have no windows to show. To the user, this is almost as if the app disappears into the status bar section of the menu bar when it's no longer being used.

PeristentMenuBarItem lets you hide your app from the Dock and App Switcher if all its windows are closed, giving this effect.

## Usage:

The most important thing in this package is the `allowsAccessoryModeWhenDismissed()` modifier.
Attach this to a View and it will report its window to a singleton `ApplicationAccessoryModeManager` for tracking. (actually that's just an implementation detail. You don't have to worry about `ApplicationAccessoryModeManager` at all.)
If all your windows (modified by `allowsAccessoryModeWhenDismissed()`) are closed by the user, then `ApplicationAccessoryModeManager` will change your app's activation policy to `.accessory` (see https://developer.apple.com/documentation/appkit/nsapplication/activationpolicy-swift.enum)

Here's an example app that presents two scenes: an onboarding window and a regular window that can have multiple instances:

    // used to enforce that only one onboarding window is created at a time
    struct OnBoardingIdentifier: Codable, Hashable {}

    @main
    struct PersistentMenuBarItemsApp: App {
        
        var body: some Scene {
            WindowGroup(id: "standard") {
                VStack {
                    Text("App's Main Window!")
                    Text("There can be multiple instances of this")
                }
                .padding()
                .allowsAccessoryModeWhenDismissed()
            }
      
            MenuBarExtra("Example Menu Bar Extra", systemImage: "balloon.2.fill") {
                MenuBarView()
                    .canBringAppBackFromAccessoryMode()
            }
            
            WindowGroup(for: OnBoardingIdentifier.self) {_ in
                VStack(alignment: .leading) {
                    Text("Onboarding Window")
                }
                .frame(width: 500, height: 500)
                .allowsAccessoryModeWhenDismissed()
            }
            .windowResizability(.contentSize)
        }
    }


But once your app is in accessory mode, how can you get it back? This is where `bringBackFromBackground` comes in. It's an environment value that provides a frunction that will return the app's activation policy to `.regular` and bring it to the front.

Here's the `MenuBarView' from the example above:

    struct MenuBarView: View {
                    
        @Environment(\.openWindow) var openWindow
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.bringBackFromBackground) var bringBackFromBackground
        
        var body: some View {
            Button("New Window…", action: newWindowButtonTapped)
                // you will this if you have set the
                // menuBarExtraStyle to .window
                // otherwise it's not necessary
                .contentShape(.rect)

            Divider()

            Button("Show Onboarding View…", action: onboardingButtonTapped)
            // you will this if you have set the
            // menuBarExtraStyle to .window
            // otherwise it's not necessary
                .contentShape(.rect)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(self)
            }
            // you will this if you have set the
            // menuBarExtraStyle to .window
            // otherwise it's not necessary
            .contentShape(.rect)
        }
        
        private func reactivateApp() {
            // you will need to call this if you have set the
            // menuBarExtraStyle to .window
            // otherwise it's unneeded
            // but it doesn't hurt anything if it's called
            presentationMode.wrappedValue.dismiss()

            // this brings the app back from accessory mode
            // if it's currently in accessory mode
            // and then brings the app to the foreground
            bringBackFromBackground()
        }
        
        private func onboardingButtonTapped() {
            reactivateApp()
            
            openWindow(value: OnBoardingIdentifier())
        }

        private func newWindowButtonTapped() {
            reactivateApp()

            openWindow(id: "standard")
        }
    }

The final step is to be sure that `bringBackFromBackground` is available in the environment. The easiest way to do this is to modify any view that will use it with `canBringAppBackFromAccessoryMode()`.

For example, the example app above modifies its MenuBarView with `canBringAppBackFromAccessoryMode()`:

    MenuBarView()
        .canBringAppBackFromAccessoryMode()

And that's really all there is to it.
