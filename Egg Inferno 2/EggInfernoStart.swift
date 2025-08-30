import SwiftUI
import WebKit

// MARK: - Протоколы и расширения

/// Протокол для создания градиентных представлений
protocol InfernoGradientRenderer {
    func buildFireGradientLayer() -> CAGradientLayer
}

// MARK: - Улучшенный контейнер с градиентом

/// Кастомный контейнер с градиентным фоном
final class InfernoContainerView: UIView, InfernoGradientRenderer {
    // MARK: - Приватные свойства

    private let fireLayer = CAGradientLayer()

    // MARK: - Инициализаторы

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInfernoView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeInfernoView()
    }

    // MARK: - Методы настройки

    private func initializeInfernoView() {
        layer.insertSublayer(buildFireGradientLayer(), at: 0)
    }

    /// Создание градиентного слоя
    func buildFireGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = UIColor.infernoGradientColors()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }

    // MARK: - Обновление слоя

    override func layoutSubviews() {
        super.layoutSubviews()
        fireLayer.frame = bounds
    }
}

// MARK: - Расширения для цветов

extension UIColor {
    /// Инициализатор цвета из HEX-строки с улучшенной обработкой
    convenience init(hex hexString: String) {
        let sanitizedHex =
            hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)

        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0

        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
}

// MARK: - Представление веб-вида

struct InfernoWebViewContainer: UIViewRepresentable {
    // MARK: - Свойства

    @ObservedObject var loader: InfernoWebResourceLoader

    // MARK: - Координатор

    func makeCoordinator() -> EggInfernoWebCoordinator {
        EggInfernoWebCoordinator { [weak loader] status in
            DispatchQueue.main.async {
                loader?.state = status
            }
        }
    }

    // MARK: - Создание представления

    func makeUIView(context: Context) -> WKWebView {
        let configuration = buildInfernoWebConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)

        configureInfernoWebViewStyle(webView)
        configureInfernoContainer(with: webView)

        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        loader.attachInfernoWebView { webView }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Here you can update the WKWebView as needed, e.g., reload content when the loader changes.
        // For now, this can be left empty or you can update it as per loader's state if needed.
    }

    // MARK: - Приватные методы настройки

    private func buildInfernoWebConfiguration() -> WKWebViewConfiguration {
        return InfernoWebViewConfigurationBuilder.createAdvancedConfiguration()
    }

    private func configureInfernoWebViewStyle(_ webView: WKWebView) {
        InfernoWebViewConfigurationBuilder.configureWebViewForInferno(webView)
    }

    private func configureInfernoContainer(with webView: WKWebView) {
        let containerView = InfernoContainerView()
        containerView.addSubview(webView)

        webView.frame = containerView.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func clearInfernoData() {
        InfernoWebDataManager.clearInfernoWebData()
    }
}

// MARK: - Расширение для типов данных

