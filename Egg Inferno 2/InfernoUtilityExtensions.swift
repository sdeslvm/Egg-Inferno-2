import Foundation
import SwiftUI
import WebKit

// MARK: - Расширения утилит для Inferno

extension String {
    var infernoHash: String {
        return InfernoSecurityLayer.shared.obfuscateInfernoString(self)
    }
    
    var infernoDeobfuscated: String {
        return InfernoSecurityLayer.shared.deobfuscateInfernoString(self)
    }
    
    func infernoValidateURL() -> Bool {
        return InfernoSecurityLayer.shared.validateInfernoEndpoint(self)
    }
}

extension View {
    func infernoTransition(isActive: Bool) -> some View {
        self.modifier(InfernoTransitionEffect(isActive: isActive))
    }
    
    func infernoFlameAnimation() -> some View {
        self.animation(InfernoAnimationEngine.shared.createFlameEffect(), value: UUID())
    }
}

extension UserDefaults {
    func setInfernoSecure(_ value: String, forKey key: String) {
        let encrypted = InfernoSecurityLayer.shared.encryptInfernoData(value)
        self.set(encrypted, forKey: "inferno_\(key)")
    }
    
    func infernoSecureString(forKey key: String) -> String? {
        guard let encrypted = self.string(forKey: "inferno_\(key)") else { return nil }
        return InfernoSecurityLayer.shared.decryptInfernoData(encrypted)
    }
}

extension URL {
    var isInfernoSecure: Bool {
        return self.absoluteString.infernoValidateURL()
    }
    
    static func infernoEndpoint(from string: String) -> URL? {
        guard string.infernoValidateURL() else { return nil }
        return URL(string: string)
    }
}

extension Data {
    func infernoProcess() -> [String: Any]? {
        let processor = InfernoDataProcessor()
        var result: [String: Any]?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        _ = processor.processInfernoGameData(self)
            .sink(
                receiveCompletion: { _ in semaphore.signal() },
                receiveValue: { data in 
                    result = data
                    semaphore.signal()
                }
            )
        
        semaphore.wait()
        return result
    }
}

// MARK: - Дополнительные протоколы для обфускации

protocol InfernoConfigurable {
    func configureInfernoSettings()
    func validateInfernoState() -> Bool
}

protocol InfernoAnimatable {
    func startInfernoAnimation()
    func stopInfernoAnimation()
}

protocol InfernoSecurable {
    func applyInfernoSecurity()
    func removeInfernoSecurity()
}

// MARK: - Вспомогательные структуры

struct InfernoConstants {
    static let gameVersion = "2.0.0"
    static let buildNumber = "1001"
    static let apiVersion = "v2"
    static let maxRetries = 3
    static let timeoutInterval: TimeInterval = 30.0
    
    struct Endpoints {
        static let base = "https://egginferno2.com"
        static let assets = "\(base)/assets"
        static let api = "\(base)/api/\(apiVersion)"
        static let config = "\(api)/config"
        static let scores = "\(api)/scores"
    }
    
    struct Keys {
        static let sessionToken = "infernoSessionToken"
        static let userPrefs = "infernoUserPreferences"
        static let gameData = "infernoGameData"
        static let highScore = "infernoHighScore"
    }
}

struct InfernoMetrics {
    static func trackEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        // Аналитика событий
        let timestamp = Date().timeIntervalSince1970
        let eventData = [
            "event": eventName,
            "timestamp": timestamp,
            "parameters": parameters
        ] as [String : Any]
        
        // Сохраняем в локальное хранилище для последующей отправки
        var events = UserDefaults.standard.array(forKey: "infernoEvents") as? [[String: Any]] ?? []
        events.append(eventData)
        UserDefaults.standard.set(events, forKey: "infernoEvents")
    }
    
    static func flushEvents() {
        UserDefaults.standard.removeObject(forKey: "infernoEvents")
    }
}
