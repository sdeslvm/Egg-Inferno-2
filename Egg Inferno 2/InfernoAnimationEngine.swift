import SwiftUI
import UIKit

// MARK: - Анимационный движок для Inferno

class InfernoAnimationEngine {
    static let shared = InfernoAnimationEngine()
    
    private init() {}
    
    func createFlameEffect() -> Animation {
        return Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)
    }
    
    func createEmberShimmer() -> Animation {
        return Animation.linear(duration: 2.0).repeatForever(autoreverses: false)
    }
    
    func createPulseEffect() -> Animation {
        return Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    }
}

// MARK: - Частицы для анимации

struct InfernoParticle {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
    let scale: CGFloat
    
    init(x: CGFloat, y: CGFloat, opacity: Double = 0.8, scale: CGFloat = 1.0) {
        self.x = x
        self.y = y
        self.opacity = opacity
        self.scale = scale
    }
}

class InfernoParticleSystem: ObservableObject {
    @Published var particles: [InfernoParticle] = []
    
    func generateFireParticles(count: Int, width: CGFloat, height: CGFloat) {
        particles = (0..<count).map { _ in
            InfernoParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 0...height),
                opacity: Double.random(in: 0.3...0.9),
                scale: CGFloat.random(in: 0.5...1.5)
            )
        }
    }
    
    func updateParticlePositions() {
        particles = particles.map { particle in
            InfernoParticle(
                x: particle.x + CGFloat.random(in: -2...2),
                y: particle.y + CGFloat.random(in: -1...1),
                opacity: max(0.1, particle.opacity - 0.01),
                scale: particle.scale
            )
        }
    }
}

// MARK: - Эффекты переходов

struct InfernoTransitionEffect: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.6)
            .animation(InfernoAnimationEngine.shared.createFlameEffect(), value: isActive)
    }
}
