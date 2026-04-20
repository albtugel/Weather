import UIKit

enum AppTextStyle {
    case largeTitle
    case title
    case subtitle
    case body
    case caption
    case temperature

    var font: UIFont {
        switch self {
        case .largeTitle:   return .systemFont(ofSize: 34, weight: .bold)
        case .title:        return .systemFont(ofSize: 22, weight: .semibold)
        case .subtitle:     return .systemFont(ofSize: 17, weight: .medium)
        case .body:         return .systemFont(ofSize: 15, weight: .regular)
        case .caption:      return .systemFont(ofSize: 12, weight: .regular)
        case .temperature:  return .systemFont(ofSize: 80, weight: .thin)
        }
    }
}
