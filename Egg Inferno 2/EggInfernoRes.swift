import Combine
import SwiftUI
import WebKit

// MARK: - Протоколы

/// Протокол для управления состоянием веб-загрузки
protocol WebLoadable: AnyObject {
    var state: EggInfernoWebStatus { get set }
    func setConnectivity(_ available: Bool)
}

/// Протокол для мониторинга прогресса загрузки
protocol ProgressMonitoring {
    func observeProgression()
    func monitor(_ webView: WKWebView)
}

// MARK: - Основной загрузчик веб-представления

/// Класс для управления загрузкой и состоянием веб-представления
final class InfernoWebResourceLoader: NSObject, ObservableObject, WebLoadable, ProgressMonitoring {
    // MARK: - Свойства

    @Published var state: EggInfernoWebStatus = .standby

    let infernoEndpoint: URL
    private var infernoSubscriptions = Set<AnyCancellable>()
    private var infernoProgressStream = PassthroughSubject<Double, Never>()
    private var infernoViewFactory: (() -> WKWebView)?

    // MARK: - Инициализация

    init(resourceURL: URL) {
        self.infernoEndpoint = resourceURL
        super.init()
        observeProgression()
    }

    // MARK: - Публичные методы

    /// Привязка веб-представления к загрузчику
    func attachInfernoWebView(factory: @escaping () -> WKWebView) {
        infernoViewFactory = factory
        initiateInfernoLoad()
    }

    /// Установка доступности подключения
    func setConnectivity(_ available: Bool) {
        switch (available, state) {
        case (true, .noConnection):
            initiateInfernoLoad()
        case (false, _):
            state = .noConnection
        default:
            break
        }
    }

    // MARK: - Приватные методы загрузки

    /// Запуск загрузки веб-представления
    private func initiateInfernoLoad() {
        guard let webView = infernoViewFactory?() else { return }

        let request = URLRequest(url: infernoEndpoint, timeoutInterval: 12)
        state = .progressing(progress: 0)

        webView.navigationDelegate = self
        webView.load(request)
        monitorInfernoProgress(webView)
    }

    // MARK: - Методы мониторинга

    /// Наблюдение за прогрессом загрузки
    func observeProgression() {
        startInfernoProgressMonitoring()
    }
    
    private func startInfernoProgressMonitoring() {
        infernoProgressStream
            .removeDuplicates()
            .sink { [weak self] progress in
                guard let self else { return }
                self.state = progress < 1.0 ? .progressing(progress: progress) : .finished
            }
            .store(in: &infernoSubscriptions)
    }

    /// Мониторинг прогресса веб-представления
    func monitor(_ webView: WKWebView) {
        monitorInfernoProgress(webView)
    }
    
    private func monitorInfernoProgress(_ webView: WKWebView) {
        webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] progress in
                self?.infernoProgressStream.send(progress)
            }
            .store(in: &infernoSubscriptions)
    }
}

// MARK: - Расширение для обработки навигации

extension InfernoWebResourceLoader: WKNavigationDelegate {
    /// Обработка ошибок при навигации
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }

    /// Обработка ошибок при provisional навигации
    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        handleNavigationError(error)
    }

    // MARK: - Приватные методы обработки ошибок

    /// Обобщенный метод обработки ошибок навигации
    private func handleNavigationError(_ error: Error) {
        state = .failure(reason: error.localizedDescription)
    }
}

// MARK: - Расширения для улучшения функциональности

extension InfernoWebResourceLoader {
    /// Создание загрузчика с безопасным URL
    convenience init?(urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.init(resourceURL: url)
    }
}
