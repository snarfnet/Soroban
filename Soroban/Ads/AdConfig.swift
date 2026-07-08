import Foundation

enum AdConfig {
    // Amazonアソシエイト トラッキングID
    static let affiliateTag = "kixyouhueizou-22"

    struct Promo {
        let icon: String
        let title: String
        let keyword: String

        var url: URL? {
            let q = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
            return URL(string: "https://www.amazon.co.jp/s?k=\(q)&tag=\(AdConfig.affiliateTag)")
        }
    }

    // 下部バナーでローテーション表示するそろばん関連のAmazon商品カテゴリ
    static let promos: [Promo] = [
        Promo(icon: "🧮", title: "本物のそろばんを見る", keyword: "そろばん"),
        Promo(icon: "📚", title: "そろばん・暗算ドリル", keyword: "そろばん ドリル"),
        Promo(icon: "🎓", title: "算数の知育玩具", keyword: "知育玩具 算数"),
        Promo(icon: "🔢", title: "電卓・計算機を見る", keyword: "電卓"),
    ]
}
