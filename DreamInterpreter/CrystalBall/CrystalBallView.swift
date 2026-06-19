//
//  CrystalBallView.swift
//  DreamInterpreter
//
//  Created by John Martino on 6/19/26.
//

import SwiftUI

/// A glowing crystal ball whose interior is filled with a swirling,
/// fractal silver/white plasma. The plasma is generated entirely on the GPU
/// by the `crystalPlasma` Metal shader and animated with a `TimelineView`.
struct CrystalBallView: View {
    /// Diameter of the orb in points.
    var diameter: CGFloat = 300
    /// Darkest/coolest current color in the plasma palette.
    var coolColor: Color = Color(red: 0.62, green: 0.68, blue: 0.80)
    /// Brightest/hottest core color in the plasma palette.
    var hotColor: Color = .white
    /// When false, the blurred halo layer and shadow glows are suppressed.
    var glowEnabled: Bool = true

    private let startDate = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince(startDate)

            ZStack {
                // Soft outer halo so the orb appears to glow into its surroundings.
                if glowEnabled {
                    plasma(time: time)
                        .blur(radius: diameter * 0.12)
                        .opacity(0.7)
                        .blendMode(.screen)
                }

                // The crisp orb itself.
                plasma(time: time)
            }
            .frame(width: diameter, height: diameter)
            // A faint glassy edge highlight to sell the "ball" surface.
            .overlay {
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.7), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            // Ambient glow cast onto the background.
            .shadow(color: hotColor.opacity(glowEnabled ? 0.35 : 0), radius: diameter * 0.18)
            .shadow(color: coolColor.opacity(glowEnabled ? 0.4 : 0), radius: diameter * 0.3)
        }
    }

    /// One layer of the shader-driven plasma, sized to a square the shader
    /// can map a sphere into.
    private func plasma(time: TimeInterval) -> some View {
        Rectangle()
            .fill(.black)
            .colorEffect(
                ShaderLibrary.crystalPlasma(
                    .float2(diameter, diameter),
                    .float(time),
                    .color(coolColor),
                    .color(hotColor)
                )
            )
            .frame(width: diameter, height: diameter)
    }
}

#Preview("Silver (default)") {
    CrystalBallView()
        .padding(60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}

#Preview("Fire") {
    CrystalBallView(
        coolColor: Color(red: 0.9, green: 0.3, blue: 0.0),
        hotColor:  Color(red: 1.0, green: 0.95, blue: 0.2)
    )
    .padding(60)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}
