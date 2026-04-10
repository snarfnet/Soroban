import SwiftUI
import SpriteKit
import GoogleMobileAds

@main
struct SorobanApp: App {
    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
