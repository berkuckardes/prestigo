//
//  RootView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import SwiftUI

final class AppSession: ObservableObject {
    @Published var isLoggedIn: Bool = true // Later: replace with Firebase auth check
}

struct RootView: View {
    @StateObject private var session = AppSession()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // Main content
            Group {
                if session.isLoggedIn {
                    CustomTabsRoot()
                        .environmentObject(session)
                } else {
                    OnboardingView()
                        .environmentObject(session)
                }
            }
            .opacity(showSplash ? 0 : 1)

            // Splash overlay
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

