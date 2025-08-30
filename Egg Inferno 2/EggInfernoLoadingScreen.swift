import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct InfernoLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo на весь экран с блюром + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width * 2, height: geo.size.height * 2)
                    .clipped()
                    .ignoresSafeArea(.all)
                    .blur(radius: 34)
                    .overlay(Color.black.opacity(0.3))
                    
                    

                // Адаптивная компоновка для портретной и горизонтальной ориентации
                if geo.size.width > geo.size.height {
                    // Горизонтальная ориентация
                    HStack {
                        Spacer()
                        
                        // Логотип слева
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                            .frame(width: geo.size.width * 0.25, height: geo.size.height * 0.6)
                           
                            .scaleEffect(pulse ? 1.05 : 0.95)
                        
                            .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
                        
                            .animation(
                                Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                                value: pulse
                            )
                            .onAppear { pulse = true }
                         
                        
                        Spacer().frame(width: 60)
                        
                        // Прогресс справа
                        VStack(spacing: 20) {
                            Text("Loading \(progressPercentage)%")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 4, y: 2)
                            
                            InfernoProgressBar(value: progress)
                                .frame(width: geo.size.width * 0.4, height: 12)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.6))
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 15, y: 8)
                        
                        Spacer()
                    }
                } else {
                    // Портретная ориентация
                    VStack {
                        Spacer()
                        
                        // Пульсирующий логотип в верхней части
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                            .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.25)
                        
                            .scaleEffect(pulse ? 1.05 : 0.95)
                            .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
                            .animation(
                                Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                                value: pulse
                            )
                            
                            .onAppear { pulse = true }
                        
                        Spacer().frame(height: 80)
                        
                        // Прогрессбар и проценты внизу
                        VStack(spacing: 20) {
                            Text("Loading \(progressPercentage)%")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 4, y: 2)
                            
                            InfernoProgressBar(value: progress)
                                .frame(width: geo.size.width * 0.7, height: 12)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.6))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 15, y: 8)
                        
                        Spacer()
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
}

// MARK: - Фоновые представления

struct InfernoBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct InfernoProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var particles: [ProgressParticle] = []

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    startShimmerAnimation()
                    startPulseAnimation()
                    generateParticles(width: geometry.size.width)
                }
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
            particleOverlay(in: geometry)
        }
    }

    private func fireProgressionColors() -> [Color] {
        let progress = value
        
        if progress < 0.25 {
            // Начальный огонь - темно-красный к красному
            return [
                Color(red: 0.545, green: 0, blue: 0), // Темно-красный
                Color(red: 0.863, green: 0.078, blue: 0.235), // Красный
                Color(red: 1.0, green: 0.271, blue: 0), // Оранжево-красный
                Color(red: 1.0, green: 0.388, blue: 0.278)  // Томатный
            ]
        } else if progress < 0.5 {
            // Разгорающийся огонь - красный к оранжевому
            return [
                Color(red: 0.863, green: 0.078, blue: 0.235), // Красный
                Color(red: 1.0, green: 0.271, blue: 0), // Оранжево-красный
                Color(red: 1.0, green: 0.388, blue: 0.278)  // Томатный
            ]
        } else if progress < 0.75 {
            // Яркий огонь - оранжевый к желтому
            return [
                Color(red: 1.0, green: 0.271, blue: 0), // Оранжево-красный
                Color(red: 1.0, green: 0.549, blue: 0), // Темно-оранжевый
                Color(red: 1.0, green: 0.647, blue: 0)  // Оранжевый
            ]
        } else {
            // Пиковый огонь - желтый к белому
            return [
                Color(red: 1.0, green: 0.647, blue: 0), // Оранжевый
                Color(red: 1.0, green: 0.843, blue: 0), // Золотой
                Color(red: 1.0, green: 1.0, blue: 0), // Желтый
                Color.white  // Белый (самый горячий)
            ]
        }
    }
    
    private func backgroundTrack(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.039, green: 0.039, blue: 0.039), Color(red: 0.102, green: 0.102, blue: 0.18), Color(red: 0.086, green: 0.129, blue: 0.243),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0, green: 0.831, blue: 1.0).opacity(0.3),
                                Color(red: 0.482, green: 0.408, blue: 0.933).opacity(0.2),
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.4), radius: 8, y: 4)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Основной неоновый градиент
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: fireProgressionColors()),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .scaleEffect(pulseScale)
                .shadow(color: fireProgressionColors().first?.opacity(0.8) ?? Color.red.opacity(0.8), radius: 15, y: 0)
                .shadow(color: fireProgressionColors().last?.opacity(0.6) ?? Color.orange.opacity(0.6), radius: 25, y: 0)

            // Анимированный блеск
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.8),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.3, height: height)
                .offset(x: shimmerOffset * width)
                .clipped()
                .frame(width: width, height: height)

            // Внутреннее свечение
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear,
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: height / 2
                    )
                )
                .frame(width: width, height: height * 0.6)
        }
        .animation(.easeInOut(duration: 0.3), value: value)
    }

    private func particleOverlay(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width

        return ZStack {
            ForEach(particles.indices, id: \.self) { index in
                if particles[index].x <= width {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0, green: 0.831, blue: 1.0).opacity(0.8),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 2
                            )
                        )
                        .frame(width: 4, height: 4)
                        .position(x: particles[index].x, y: particles[index].y)
                        .opacity(particles[index].opacity)
                }
            }
        }
    }

    private func startShimmerAnimation() {
        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.2
        }
    }

    private func startPulseAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }

    private func generateParticles(width: CGFloat) {
        particles = (0..<15).map { _ in
            ProgressParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.3...0.9)
            )
        }
    }
}

private struct ProgressParticle {
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

// MARK: - Превью

#Preview("Vertical") {
    InfernoLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    InfernoLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
        .previewDevice("iPhone 16 Pro")
}
