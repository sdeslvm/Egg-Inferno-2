import Foundation
import SwiftUI

// MARK: - Ядро игры Inferno

class InfernoGameCore: ObservableObject {
    @Published var gameState: InfernoGameState = .initializing
    @Published var currentScore: Int = 0
    @Published var gameLevel: Int = 1
    @Published var isGameActive: Bool = false
    
    private let stateManager = InfernoStateManager()
    private let dataProcessor = InfernoDataProcessor()
    private let securityLayer = InfernoSecurityLayer.shared
    
    enum InfernoGameState: Equatable {
        case initializing
        case loading
        case ready
        case playing
        case paused
        case gameOver
        case error(String)
        
        static func == (lhs: InfernoGameState, rhs: InfernoGameState) -> Bool {
            switch (lhs, rhs) {
            case (.initializing, .initializing),
                 (.loading, .loading),
                 (.ready, .ready),
                 (.playing, .playing),
                 (.paused, .paused),
                 (.gameOver, .gameOver):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    func initializeInfernoGame() {
        gameState = .loading
        
        // Генерируем токен сессии
        let sessionToken = securityLayer.generateInfernoSessionToken()
        UserDefaults.standard.set(sessionToken, forKey: "infernoSessionToken")
        
        // Инициализируем игровые данные
        setupInfernoGameData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gameState = .ready
        }
    }
    
    private func setupInfernoGameData() {
        // Настройка начальных параметров игры
        currentScore = 0
        gameLevel = 1
        isGameActive = false
        
        // Загрузка сохраненных данных
        loadInfernoSaveData()
    }
    
    private func loadInfernoSaveData() {
        if let savedScore = UserDefaults.standard.object(forKey: "infernoSavedScore") as? Int {
            currentScore = savedScore
        }
        
        if let savedLevel = UserDefaults.standard.object(forKey: "infernoSavedLevel") as? Int {
            gameLevel = savedLevel
        }
    }
    
    func startInfernoGame() {
        guard gameState == .ready else { return }
        
        gameState = .playing
        isGameActive = true
        
        // Запускаем игровой цикл
        beginInfernoGameLoop()
    }
    
    func pauseInfernoGame() {
        guard gameState == .playing else { return }
        
        gameState = .paused
        isGameActive = false
        
        // Сохраняем текущий прогресс
        saveInfernoProgress()
    }
    
    func resumeInfernoGame() {
        guard gameState == .paused else { return }
        
        gameState = .playing
        isGameActive = true
        
        // Возобновляем игровой цикл
        beginInfernoGameLoop()
    }
    
    func endInfernoGame() {
        gameState = .gameOver
        isGameActive = false
        
        // Сохраняем финальный результат
        saveInfernoFinalScore()
    }
    
    private func beginInfernoGameLoop() {
        // Основной игровой цикл
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard self.isGameActive else {
                timer.invalidate()
                return
            }
            
            self.updateInfernoGameState()
        }
    }
    
    private func updateInfernoGameState() {
        // Обновление состояния игры
        // Здесь будет логика обновления игры
    }
    
    private func saveInfernoProgress() {
        UserDefaults.standard.set(currentScore, forKey: "infernoSavedScore")
        UserDefaults.standard.set(gameLevel, forKey: "infernoSavedLevel")
    }
    
    private func saveInfernoFinalScore() {
        let encryptedScore = securityLayer.encryptInfernoData("\(currentScore)")
        UserDefaults.standard.set(encryptedScore, forKey: "infernoFinalScore")
        
        // Очищаем временные данные
        UserDefaults.standard.removeObject(forKey: "infernoSavedScore")
        UserDefaults.standard.removeObject(forKey: "infernoSavedLevel")
    }
    
    func resetInfernoGame() {
        gameState = .initializing
        currentScore = 0
        gameLevel = 1
        isGameActive = false
        
        // Очищаем все сохраненные данные
        UserDefaults.standard.removeObject(forKey: "infernoSavedScore")
        UserDefaults.standard.removeObject(forKey: "infernoSavedLevel")
        UserDefaults.standard.removeObject(forKey: "infernoFinalScore")
        UserDefaults.standard.removeObject(forKey: "infernoSessionToken")
    }
}

// MARK: - Расширения для игровой логики

extension InfernoGameCore {
    var canStartGame: Bool {
        return gameState == .ready
    }
    
    var canPauseGame: Bool {
        return gameState == .playing
    }
    
    var canResumeGame: Bool {
        return gameState == .paused
    }
    
    var isGameInProgress: Bool {
        return gameState == .playing || gameState == .paused
    }
}
