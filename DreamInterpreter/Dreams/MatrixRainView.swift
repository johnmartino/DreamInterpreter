//
//  MatrixRainView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/7/25.
//

import SwiftUI
internal import Combine

struct MatrixRainView: View {
    private let constant = "@tfgQWERTYUIASDFGHJKLZXCVB<>?"
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            HStack(spacing: 16) {
                ForEach(1...Int(size.width / 37), id: \.self) { _ in
                    MatrixRainCharacters(constant: constant, size: size)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MatrixRainCharacters: View {
    @State private var startAnimation: Bool = false
    @State private var random: Int = 0
    
    let constant: String
    let size: CGSize
    
    var body: some View {
        let randomHeight: CGFloat = .random(in: (size.height / 2)...size.height)
        
        VStack {
            ForEach(Array(constant).indices, id: \.self) { index in
                let character = Array(constant)[getRandomIndex(index: index)]
                Text(String(character))
                    .font(.custom("Astro", size: 25))
                    .foregroundStyle(.secondary)
            }
            .frame(maxHeight: .infinity)
        }
        .mask(alignment: .top) {
            Rectangle()
                .fill(LinearGradient(gradient:
                                        Gradient(colors: [
                                            .clear,
                                            .black.opacity(0.1),
                                            .black.opacity(0.2),
                                            .black.opacity(0.3),
                                            .black.opacity(0.5),
                                            .black.opacity(0.7),
                                            .black]),
                                     startPoint: .top,
                                     endPoint: .bottom)
                )
                .frame(height: size.height / 2)
                .offset(y: startAnimation ? size.height : -randomHeight)
        }
        .onAppear {
            withAnimation(.linear(duration: 12).delay(.random(in: 0...2)).repeatForever(autoreverses: false)) {
                startAnimation = true
            }
        }
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            random = Int.random(in: 0..<constant.count)
        }
    }
    
    private func getRandomIndex(index: Int) -> Int {
        let max = constant.count - 1
        
        if (index + random) > max {
            if (index - random) < 0 {
                return index
            }
            return (index - random)
        } else {
            return (index + random)
        }
    }
}
#Preview {
    MatrixRainView()
        .ignoresSafeArea()
}
