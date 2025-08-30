import Foundation
import SwiftUI

// MARK: - Менеджер состояний для Inferno

class InfernoStateManager: ObservableObject {
    @Published var currentInfernoState: InfernoGameState = .initializing
    @Published var loadingProgress: Double = 0.0
    @Published var isNetworkAvailable: Bool = true
    @Published var errorMessage: String?
    
    private var stateTransitionHandlers: [InfernoGameState: () -> Void] = [:]
    
    enum InfernoGameState: CaseIterable {
        case initializing
        case loading
        case ready
        case playing
        case paused
        case error
        case offline
        
        var displayName: String {
            switch self {
            case .initializing: return "Инициализация"
            case .loading: return "Загрузка"
            case .ready: return "Готов"
            case .playing: return "Игра"
            case .paused: return "Пауза"
            case .error: return "Ошибка"
            case .offline: return "Оффлайн"
            }
        }
    }
    
    func transitionToState(_ newState: InfernoGameState) {
        guard currentInfernoState != newState else { return }
        
        let previousState = currentInfernoState
        currentInfernoState = newState
        
        executeStateTransition(from: previousState, to: newState)
        stateTransitionHandlers[newState]?()
    }
    
    private func executeStateTransition(from: InfernoGameState, to: InfernoGameState) {
        switch (from, to) {
        case (_, .loading):
            loadingProgress = 0.0
        case (_, .error):
            // Сохраняем состояние ошибки
            break
        case (_, .ready):
            loadingProgress = 1.0
            errorMessage = nil
        default:
            break
        }
    }
    
    func registerStateHandler(for state: InfernoGameState, handler: @escaping () -> Void) {
        stateTransitionHandlers[state] = handler
    }
    
    func updateLoadingProgress(_ progress: Double) {
        loadingProgress = min(1.0, max(0.0, progress))
        if progress >= 1.0 && currentInfernoState == .loading {
            transitionToState(.ready)
        }
    }
    
    func setError(_ message: String) {
        errorMessage = message
        transitionToState(.error)
    }
    
    func clearError() {
        errorMessage = nil
        if currentInfernoState == .error {
            transitionToState(.initializing)
        }
    }
}

// MARK: - Расширения для удобства

extension InfernoStateManager {
    var isLoading: Bool {
        return currentInfernoState == .loading || currentInfernoState == .initializing
    }
    
    var canPlay: Bool {
        return currentInfernoState == .ready && isNetworkAvailable
    }
    
    var shouldShowError: Bool {
        return currentInfernoState == .error && errorMessage != nil
    }
}
