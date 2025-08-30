import Foundation
import Combine

// MARK: - Процессор данных для Inferno

class InfernoDataProcessor: ObservableObject {
    @Published var processingState: ProcessingState = .idle
    @Published var dataCache: [String: Any] = [:]
    
    private var processingQueue = DispatchQueue(label: "inferno.data.processing", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    
    enum ProcessingState {
        case idle
        case processing
        case completed
        case failed(Error)
    }
    
    func processInfernoGameData(_ rawData: Data) -> AnyPublisher<[String: Any], Error> {
        return Future { [weak self] promise in
            self?.processingQueue.async {
                do {
                    let processedData = try self?.parseInfernoData(rawData) ?? [:]
                    DispatchQueue.main.async {
                        self?.dataCache.merge(processedData) { _, new in new }
                        self?.processingState = .completed
                        promise(.success(processedData))
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.processingState = .failed(error)
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func parseInfernoData(_ data: Data) throws -> [String: Any] {
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw InfernoDataError.invalidFormat
        }
        
        var processedData: [String: Any] = [:]
        
        // Обработка конфигурации игры
        if let gameConfig = jsonObject["gameConfig"] as? [String: Any] {
            processedData["infernoConfig"] = transformGameConfig(gameConfig)
        }
        
        // Обработка пользовательских данных
        if let userData = jsonObject["userData"] as? [String: Any] {
            processedData["infernoUserData"] = sanitizeUserData(userData)
        }
        
        // Обработка настроек
        if let settings = jsonObject["settings"] as? [String: Any] {
            processedData["infernoSettings"] = optimizeSettings(settings)
        }
        
        return processedData
    }
    
    private func transformGameConfig(_ config: [String: Any]) -> [String: Any] {
        var transformed: [String: Any] = [:]
        
        for (key, value) in config {
            let newKey = "inferno_" + key.lowercased()
            transformed[newKey] = value
        }
        
        return transformed
    }
    
    private func sanitizeUserData(_ userData: [String: Any]) -> [String: Any] {
        var sanitized: [String: Any] = [:]
        
        let allowedKeys = ["score", "level", "achievements", "preferences"]
        
        for key in allowedKeys {
            if let value = userData[key] {
                sanitized["user_" + key] = value
            }
        }
        
        return sanitized
    }
    
    private func optimizeSettings(_ settings: [String: Any]) -> [String: Any] {
        var optimized: [String: Any] = [:]
        
        for (key, value) in settings {
            if let stringValue = value as? String {
                optimized[key] = InfernoSecurityLayer.shared.encryptInfernoData(stringValue)
            } else {
                optimized[key] = value
            }
        }
        
        return optimized
    }
    
    func clearInfernoCache() {
        dataCache.removeAll()
        processingState = .idle
    }
    
    func getCachedData(for key: String) -> Any? {
        return dataCache[key]
    }
}

// MARK: - Ошибки обработки данных

enum InfernoDataError: Error, LocalizedError {
    case invalidFormat
    case processingFailed
    case cacheMiss
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Неверный формат данных Inferno"
        case .processingFailed:
            return "Ошибка обработки данных Inferno"
        case .cacheMiss:
            return "Данные не найдены в кэше Inferno"
        }
    }
}
