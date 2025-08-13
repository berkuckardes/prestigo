//
//  PrestigoReservationApp.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import SwiftUI
import Firebase

@main
struct PrestigoApp: App {
    @StateObject private var authService = AuthService()

    init() {
        FirebaseApp.configure()
        
            
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .onAppear {
                    authService.ensureSignedIn()
                }
        }
    }
}

