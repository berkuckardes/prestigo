//
//  OnboardingView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Prestigo").font(.title2).bold()
            Text("Book prestigious places, follow friends, earn points.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Continue") { session.isLoggedIn = true }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
