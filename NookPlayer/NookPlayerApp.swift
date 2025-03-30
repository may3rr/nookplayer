import SwiftUI

struct NookPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 200)
                .frame(maxWidth: 500, maxHeight: 250)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
