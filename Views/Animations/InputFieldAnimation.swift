//
//  InputFieldAnimation.swift
//  NekoTan
//
//  Created for NekoTan Swift App
//

import SwiftUI

/// A view modifier that adds animation effects to text input fields
struct InputFieldAnimation: ViewModifier {
    // MARK: - Properties
    
    /// Whether the field is currently focused
    @Binding var isFocused: Bool
    
    /// The animation type to apply
    let animationType: AnimationType
    
    /// The color to use for the animation
    let color: Color
    
    // MARK: - Animation Types
    
    /// Types of animations that can be applied to input fields
    enum AnimationType {
        /// A subtle border animation
        case border
        /// A scale animation that slightly enlarges the field when focused
        case scale
        /// A glow effect that adds a soft glow around the field when focused
        case glow
    }
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? color : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    .shadow(color: isFocused ? color.opacity(0.3) : Color.clear, radius: animationType == .glow ? 5 : 0)
            )
            .scaleEffect(isFocused && animationType == .scale ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - View Extension

extension View {
    /// Apply an animation effect to an input field
    /// - Parameters:
    ///   - isFocused: Binding to a Boolean that indicates whether the field is focused
    ///   - type: The type of animation to apply
    ///   - color: The color to use for the animation
    /// - Returns: A view with the animation applied
    func inputFieldAnimation(
        isFocused: Binding<Bool>,
        type: InputFieldAnimation.AnimationType = .border,
        color: Color = .blue
    ) -> some View {
        self.modifier(InputFieldAnimation(isFocused: isFocused, animationType: type, color: color))
    }
}

// MARK: - Custom TextField with Animation

/// A custom text field with built-in animation effects
struct AnimatedTextField: View {
    // MARK: - Properties
    
    /// The title of the field
    let title: String
    
    /// Binding to the text value
    @Binding var text: String
    
    /// Whether the field is currently focused
    @State private var isFocused: Bool = false
    
    /// The animation type to apply
    let animationType: InputFieldAnimation.AnimationType
    
    /// The color to use for the animation
    let color: Color
    
    // MARK: - Initialization
    
    /// Initialize with required properties
    init(
        title: String,
        text: Binding<String>,
        animationType: InputFieldAnimation.AnimationType = .border,
        color: Color = .pink
    ) {
        self.title = title
        self._text = text
        self.animationType = animationType
        self.color = color
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(color.opacity(0.8))
                .opacity(isFocused || !text.isEmpty ? 1 : 0.7)
                .offset(y: isFocused || !text.isEmpty ? 0 : 10)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            
            TextField("", text: $text, onEditingChanged: { editing in
                withAnimation {
                    isFocused = editing
                }
            })
            .inputFieldAnimation(isFocused: $isFocused, type: animationType, color: color)
        }
    }
}

// MARK: - Custom TextEditor with Animation

/// A custom text editor with built-in animation effects
struct AnimatedTextEditor: View {
    // MARK: - Properties
    
    /// The title of the field
    let title: String
    
    /// Binding to the text value
    @Binding var text: String
    
    /// Whether the field is currently focused
    @State private var isFocused: Bool = false
    
    /// The animation type to apply
    let animationType: InputFieldAnimation.AnimationType
    
    /// The color to use for the animation
    let color: Color
    
    // MARK: - Initialization
    
    /// Initialize with required properties
    init(
        title: String,
        text: Binding<String>,
        animationType: InputFieldAnimation.AnimationType = .border,
        color: Color = .pink
    ) {
        self.title = title
        self._text = text
        self.animationType = animationType
        self.color = color
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(color.opacity(0.8))
                .opacity(isFocused || !text.isEmpty ? 1 : 0.7)
                .offset(y: isFocused || !text.isEmpty ? 0 : 10)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            
            TextEditor(text: $text)
                .frame(minHeight: 100)
                .onAppear {
                    NotificationCenter.default.addObserver(
                        forName: UIResponder.keyboardWillShowNotification,
                        object: nil,
                        queue: .main,
                        using: { _ in
                            self.isFocused = true
                        })
                    
                    NotificationCenter.default.addObserver(
                        forName: UIResponder.keyboardWillHideNotification,
                        object: nil,
                        queue: .main,
                        using: { _ in
                            self.isFocused = false
                        })
                }
                .inputFieldAnimation(isFocused: $isFocused, type: animationType, color: color)
        }
    }
}

// MARK: - Preview

struct InputFieldAnimation_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AnimatedTextField(
                title: "Diary Title",
                text: .constant("My Diary Entry"),
                animationType: .border,
                color: .pink
            )
            
            AnimatedTextField(
                title: "Tags",
                text: .constant("daily, thoughts"),
                animationType: .glow,
                color: .blue
            )
            
            AnimatedTextEditor(
                title: "Content",
                text: .constant("Today was a wonderful day..."),
                animationType: .scale,
                color: .purple
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}