//
//  SplashView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void
    
    // Modern animation states
    @State private var backgroundOpacity: Double = 0.0
    
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var logoOffset: CGFloat = 50
    
    @State private var taglineOpacity: Double = 0.0
    @State private var taglineOffset: CGFloat = 30
    
    @State private var accentLineWidth: CGFloat = 0.0
    @State private var accentLineOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background image
            Image("wine_toast_background") // You'll need to add this image to your Assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
            
            // Dark overlay for better text readability
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
            
            // Main content
            VStack(spacing: 32) {
                Spacer()
                
                // Modern PRESTIGO text
                ZStack {
                    // Subtle glow effect
                    Text("PRESTIGO")
                        .font(.system(size: 52, weight: .heavy, design: .default))
                        .foregroundStyle(.white.opacity(0.15))
                        .blur(radius: 15)
                        .scaleEffect(logoScale * 1.1)
                        .opacity(logoOpacity)
                    
                    // Main text with iOS native styling
                    Text("PRESTIGO")
                        .font(.system(size: 52, weight: .heavy, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    Color(red: 0.9, green: 0.9, blue: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .offset(y: logoOffset)
                }
                
                // Accent line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.red, Color(red: 0.8, green: 0.1, blue: 0.1), .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .frame(width: accentLineWidth)
                    .opacity(accentLineOpacity)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                
                // Modern tagline
                HStack(spacing: 16) {
                    ForEach(["Bookings", "Friends", "Points"], id: \.self) { word in
                        Text(word)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .opacity(taglineOpacity)
                            .offset(y: taglineOffset)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startModernAnimationSequence()
        }
    }
    
    private func startModernAnimationSequence() {
        // Background fade in
        withAnimation(.easeIn(duration: 1.0)) {
            backgroundOpacity = 1.0
        }
        
        // Logo animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
                logoOffset = 0
            }
        }
        
        // Accent line animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                accentLineWidth = 200  // Longer to match PRESTIGO text length
                accentLineOpacity = 1.0
            }
        }
        
        // Tagline animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                taglineOpacity = 1.0
                taglineOffset = 0
            }
        }
        
        // Hold for 3 more seconds (6.5s total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                logoOpacity = 0.0
                taglineOpacity = 0.0
                accentLineOpacity = 0.0
                backgroundOpacity = 0.0
            }
            
            // Call completion after fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView {
        print("Splash finished!")
    }
}

