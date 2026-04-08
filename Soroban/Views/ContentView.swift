import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var sorobanState = SorobanState()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.12, green: 0.10, blue: 0.08)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Digital display
                    displayBar
                        .frame(height: 44)

                    // Soroban SpriteKit view
                    SpriteView(scene: makeScene(size: CGSize(
                        width: geo.size.width,
                        height: geo.size.height - 44 - 50
                    )))
                    .ignoresSafeArea(edges: .horizontal)

                    // Bottom bar: reset + ad space
                    bottomBar
                        .frame(height: 50)
                }
            }
        }
        .statusBarHidden(true)
    }

    private var displayBar: some View {
        HStack {
            Spacer()
            Text(sorobanState.displayValue)
                .font(.system(size: 28, weight: .light, design: .monospaced))
                .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.08, green: 0.06, blue: 0.04))
    }

    private var bottomBar: some View {
        HStack {
            Button {
                NotificationCenter.default.post(name: .sorobanReset, object: nil)
                sorobanState.displayValue = "0"
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(red: 0.7, green: 0.6, blue: 0.5))
                    .padding(10)
            }

            Spacer()

            // Ad placeholder area
            Text("AD")
                .font(.caption2)
                .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.3))
                .frame(width: 320, height: 40)
                .background(Color(red: 0.1, green: 0.08, blue: 0.06))
                .cornerRadius(4)

            Spacer()

            // Empty spacer for balance
            Color.clear
                .frame(width: 38, height: 38)
        }
        .padding(.horizontal, 8)
        .background(Color(red: 0.08, green: 0.06, blue: 0.04))
    }

    private func makeScene(size: CGSize) -> SorobanScene {
        let scene = SorobanScene(size: size)
        scene.scaleMode = .resizeFill
        scene.sorobanState = sorobanState
        return scene
    }
}

class SorobanState: ObservableObject {
    @Published var displayValue: String = "0"
}

extension Notification.Name {
    static let sorobanReset = Notification.Name("sorobanReset")
    static let sorobanValueChanged = Notification.Name("sorobanValueChanged")
}
