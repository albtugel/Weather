import UIKit

extension UILabel {
    func apply(style: AppTextStyle, color: UIColor = AppColorManager.textPrimary) {
        font = style.font
        textColor = color
    }
}
