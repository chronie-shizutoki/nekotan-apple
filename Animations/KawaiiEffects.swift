//
//  KawaiiEffects.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI
import CoreGraphics

/// A modifier that adds a bouncing animation to any view
struct BounceAnimation: ViewModifier {
    /// The strength of the bounce effect
    let strength: Double
    
    /// The duration of the bounce animation
    let duration: Double
    
    /// The delay before the animation starts
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(1.0)
            .animation(
                Animation
                    .spring(response: duration, dampingFraction: strength)
                    .delay(delay)
                    .repeatForever(autoreverses: true),
                value: UUID()
            )
    }
}

/// A modifier that adds a floating animation to any view
struct FloatAnimation: ViewModifier {
    /// The amplitude of the floating effect
    let amplitude: CGFloat
    
    /// The frequency of the floating effect
    let frequency: Double
    
    /// The offset of the view
    @State private var offsetY: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .onAppear {
                withAnimation(Animation
                    .easeInOut(duration: frequency)
                    .repeatForever(autoreverses: true)
                ) {
                    offsetY = -amplitude
                }
            }
    }
}

/// A modifier that adds a sparkling effect to any view
struct SparkleAnimation: ViewModifier {
    /// The number of sparkles to generate
    let count: Int
    
    /// The color of the sparkles
    let color: Color
    
    /// The size of the sparkles
    let size: CGFloat
    
    /// The duration of the sparkle animation
    let duration: Double
    
    /// The sparkles generated
    @State private var sparkles: [Sparkle] = []
    
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { geometry in
                ZStack {
                    ForEach(sparkles) { sparkle in
                        Circle()
                            .fill(color)
                            .frame(width: sparkle.size, height: sparkle.size)
                            .position(x: sparkle.x, y: sparkle.y)
                            .opacity(sparkle.opacity)
                            .animation(
                                Animation
                                    .easeOut(duration: duration)
                                    .repeatForever(autoreverses: true),
                                value: sparkle.opacity
                            )
                    }
                }
                .onAppear {
                    generateSparkles(in: geometry.size, count: count)
                }
            })
    }
    
    /// Sparkle model for animation
    private struct Sparkle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        @State var opacity: Double = 0
    }
    
    /// Generate sparkles at random positions
    private func generateSparkles(in size: CGSize, count: Int) {
        for _ in 0..<count {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let sparkleSize = CGFloat.random(in: size * 0.2...size)
            
            let sparkle = Sparkle(x: x, y: y, size: sparkleSize)
            sparkles.append(sparkle)
            
            // Animate the sparkle's opacity with a random delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                if let index = sparkles.firstIndex(where: { $0.id == sparkle.id }) {
                    sparkles[index].opacity = 1.0
                }
            }
        }
    }
}

/// A modifier that adds a gradient border to any view
struct KawaiiBorder: ViewModifier {
    /// The color of the border gradient
    let colors: [Color]
    
    /// The width of the border
    let width: CGFloat
    
    /// The corner radius of the border
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .cornerRadius(cornerRadius)
                    .padding(-width)
            )
            .background(Color.white)
            .cornerRadius(cornerRadius)
    }
}

/// A modifier that adds a wavy background effect
struct WavyBackground: ViewModifier {
    /// The color of the wave
    let color: Color
    
    /// The height of the wave
    let height: CGFloat
    
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                WaveShape(height: height, amplitude: 10)
                    .fill(color.opacity(0.3))
                    .frame(height: height * 2)
            }
        }
    }
    
    /// Wave shape for the background
    private struct WaveShape: Shape {
        let height: CGFloat
        let amplitude: CGFloat
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            
            path.move(to: CGPoint(x: 0, y: rect.maxY))
            
            for x in stride(from: 0, to: width, by: 5) {
                let y = height + sin(CGFloat(x) / width * .pi * 2) * amplitude
                path.addLine(to: CGPoint(x: x, y: rect.maxY - y))
            }
            
            path.addLine(to: CGPoint(x: width, y: rect.maxY))
            path.closeSubpath()
            
            return path
        }
    }
}

/// Extension to apply kawaii animations to any view
extension View {
    /// Adds a bounce animation to the view
    func bounceAnimation(strength: Double = 0.5, duration: Double = 0.8, delay: Double = 0) -> some View {
        modifier(BounceAnimation(strength: strength, duration: duration, delay: delay))
    }
    
    /// Adds a floating animation to the view
    func floatAnimation(amplitude: CGFloat = 5, frequency: Double = 3) -> some View {
        modifier(FloatAnimation(amplitude: amplitude, frequency: frequency))
    }
    
    /// Adds a sparkle animation to the view
    func sparkleAnimation(count: Int = 10, color: Color = .yellow, size: CGFloat = 3, duration: Double = 1.5) -> some View {
        modifier(SparkleAnimation(count: count, color: color, size: size, duration: duration))
    }
    
    /// Adds a cute gradient border to the view
    func kawaiiBorder(colors: [Color] = [.pink, .purple, .blue], width: CGFloat = 3, cornerRadius: CGFloat = 10) -> some View {
        modifier(KawaiiBorder(colors: colors, width: width, cornerRadius: cornerRadius))
    }
    
    /// Adds a wavy background to the view
    func wavyBackground(color: Color = .pink, height: CGFloat = 30) -> some View {
        modifier(WavyBackground(color: color, height: height))
    }
}