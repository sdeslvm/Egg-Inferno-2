import Foundation
import SwiftUI
import UIKit

// MARK: - Цветовые утилиты для Inferno

struct InfernoColorPalette {
    static let primaryFire = "#FF6B35"
    static let secondaryFire = "#F7931E"
    static let darkFlame = "#C5351F"
    static let lightFlame = "#FFE66D"
    static let emberGlow = "#FF9F1C"
}

extension UIColor {
    /// Создание цвета из HEX для Inferno темы
    static func infernoColor(hex: String) -> UIColor {
        let sanitizedHex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0
        
        return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
    
    /// Градиент для огненной темы
    static func infernoGradientColors() -> [CGColor] {
        return [
            UIColor.infernoColor(hex: InfernoColorPalette.primaryFire).cgColor,
            UIColor.infernoColor(hex: InfernoColorPalette.secondaryFire).cgColor,
            UIColor.infernoColor(hex: InfernoColorPalette.emberGlow).cgColor
        ]
    }
}

extension Color {
    /// SwiftUI версия цветов Inferno
    static func infernoTheme(hex: String) -> Color {
        let sanitizedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        return Color(
            .sRGB,
            red: Double((colorValue >> 16) & 0xFF) / 255.0,
            green: Double((colorValue >> 8) & 0xFF) / 255.0,
            blue: Double(colorValue & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

// MARK: - Анимационные утилиты

struct InfernoAnimationConfig {
    static let defaultDuration: Double = 0.8
    static let pulseDuration: Double = 1.2
    static let shimmerDuration: Double = 2.0
    
    static func createFlameAnimation() -> Animation {
        return Animation.easeInOut(duration: pulseDuration).repeatForever(autoreverses: true)
    }
    
    static func createEmberAnimation() -> Animation {
        return Animation.linear(duration: shimmerDuration).repeatForever(autoreverses: false)
    }
}
