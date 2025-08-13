//
//  SplashView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black.opacity(0.95), .gray.opacity(0.9)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // Replace "AppLogo" with your asset name (Assets.xcassets)
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(radius: 12)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                            scale = 1.0
                        }
                        withAnimation(.easeIn(duration: 0.6)) {
                            opacity = 1.0
                        }
                    }

                Text("Prestigo")
                    .font(.title.bold())
                    .foregroundStyle(.white.opacity(0.95))

                Text("Prestige bookings • Friends • Points")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 24)
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_200_000_000) // ~2.2s
            withAnimation(.easeInOut(duration: 0.35)) { opacity = 0 }
            try? await Task.sleep(nanoseconds: 350_000_000)
            onFinished()
        }
    }
}

