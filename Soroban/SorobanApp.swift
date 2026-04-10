import SwiftUI
import SpriteKit
import GoogleMobileAds

@main
struct SorobanApp: App {
    init() {
        GADMobileAds.sharedInstance().start { _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
