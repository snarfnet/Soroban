import SwiftUI

/// Amazonアソシエイトの自前バナー。数種のそろばん関連カテゴリをローテーション表示し、
/// タップでタグ付きAmazon検索ページをSafariで開く。
struct BannerAdView: View {
    @State private var index = 0
    private let promos = AdConfig.promos
    private let timer = Timer.publish(every: 8, on: .main, in: .common).autoconnect()

    var body: some View {
        let promo = promos[index]
        Button {
            if let url = promo.url {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 8) {
                Text(promo.icon)
                    .font(.system(size: 18))
                Text(promo.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(red: 0.95, green: 0.9, blue: 0.78))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 4)
                Text("Amazon")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.6, blue: 0.0))
            }
            .padding(.horizontal, 12)
            .frame(width: 320, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.18, green: 0.14, blue: 0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.35, green: 0.28, blue: 0.20), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onReceive(timer) { _ in
            index = (index + 1) % promos.count
        }
    }
}
