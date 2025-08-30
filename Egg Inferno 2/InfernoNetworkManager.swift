import Foundation
import Network

// MARK: - Сетевой менеджер для Inferno

class InfernoNetworkManager: ObservableObject {
    @Published var isConnected = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "InfernoNetworkMonitor")
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    func checkInfernoConnection() -> Bool {
        return isConnected
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Утилиты для работы с URL

extension InfernoNetworkManager {
    static func buildInfernoURL(from baseURL: String) -> URL? {
        guard let url = URL(string: baseURL) else { return nil }
        return url
    }
    
    static func validateInfernoEndpoint(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme == "https" && url.host != nil
    }
}
