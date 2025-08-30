import Foundation
import SwiftUI

// Перенесено в InfernoColorUtilities.swift

struct EggInfernoGameInitialView: View {
    private var infernoGameEndpoint: URL { URL(string: "https://egginferno2.com/assets")! }

    var body: some View {
        ZStack {
            Color.infernoTheme(hex: "#000")
                .ignoresSafeArea()
            EggInfernoEntryScreen(loader: .init(resourceURL: infernoGameEndpoint))
        }
    }
}

#Preview {
    EggInfernoGameInitialView()
}

// Перенесено в InfernoColorUtilities.swift
