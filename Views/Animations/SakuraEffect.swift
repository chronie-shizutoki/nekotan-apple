//
//  SakuraEffect.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI

/// A view modifier that adds a sakura (cherry blossom) falling animation effect
struct SakuraEffect: ViewModifier {
    // MARK: - Properties
    
    /// Number of petals to display
    private let petalCount: Int
    
    /// Animation state
    @State private var petals: [Petal] = []
    
    // MARK: - Initialization
    
    /// Initialize with a specific number of petals
    init(petalCount: Int = 50) {
        self.petalCount = petalCount
    }
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // Sakura petals layer
            ZStack {
                ForEach(petals) { petal in
                    SakuraPetal()
                        .frame(width: petal.size, height: petal.size)
                        .foregroundColor(Color.pink.opacity(0.7))
                        .position(petal.position)
                        .rotationEffect(.degrees(petal.rotation))
                        .animation(
                            Animation
                                .linear(duration: petal.animationDuration)
                                .repeatForever(autoreverses: false),
                            value: petal.position
                        )
                }
            }
            .onAppear {
                generatePetals()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Generate random petals
    private func generatePetals() {
        petals = (0..<petalCount).map { _ in
            Petal()
        }
    }
}

// MARK: - Petal Model

/// Model representing a single sakura petal
struct Petal: Identifiable {
    /// Unique identifier
    let id = UUID()
    
    /// Current position
    var position: CGPoint
    
    /// Petal size
    let size: CGFloat
    
    /// Rotation angle
    let rotation: Double
    
    /// Animation duration
    let animationDuration: Double
    
    /// Initialize with random properties
    init() {
        // Random starting position at the top of the screen with random X
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Start above the screen
        let startY = -50.0
        
        // Initial position
        position = CGPoint(
            x: CGFloat.random(in: 0...screenWidth),
            y: CGFloat(startY)
        )
        
        // Animate to a position at the bottom of the screen
        // with some horizontal movement
        let endX = CGFloat.random(in: 0...screenWidth)
        let endY = screenHeight + 50
        
        position = CGPoint(x: endX, y: endY)
        
        // Random size between 10 and 30 points
        size = CGFloat.random(in: 10...30)
        
        // Random rotation
        rotation = Double.random(in: 0...360)
        
        // Random animation duration between 5 and 15 seconds
        animationDuration = Double.random(in: 5...15)
    }
}

// MARK: - Sakura Petal Shape

/// Custom shape for a sakura petal
struct SakuraPetal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create a petal shape
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height / 2
        
        // Draw a simple petal shape
        path.move(to: CGPoint(x: centerX, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: width, y: centerY),
            control: CGPoint(x: width * 0.8, y: height * 0.1)
        )
        path.addQuadCurve(
            to: CGPoint(x: centerX, y: height),
            control: CGPoint(x: width * 0.8, y: height * 0.9)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: centerY),
            control: CGPoint(x: width * 0.2, y: height * 0.9)
        )
        path.addQuadCurve(
            to: CGPoint(x: centerX, y: 0),
            control: CGPoint(x: width * 0.2, y: height * 0.1)
        )
        
        return path
    }
}

// MARK: - View Extension

extension View {
    /// Apply the sakura effect to a view
    func sakuraEffect(petalCount: Int = 50) -> some View {
        self.modifier(SakuraEffect(petalCount: petalCount))
    }
}

// MARK: - Preview

struct SakuraEffect_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            Text("Sakura Effect")
                .font(.largeTitle)
        }
        .sakuraEffect()
    }
}