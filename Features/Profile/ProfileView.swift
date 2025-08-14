//
//  ProfileView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @EnvironmentObject var auth: AuthService
    @State private var apple = AppleSignInCoordinator()
    @State private var showProfileSetup = false
    @State private var showAddFriends = false
    @State private var showMenu = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Profile Card
                    VStack(spacing: 16) {
                        // Profile Picture
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 8) {
                            Text(auth.user?.displayName ?? "Guest User")
                                .font(.title2)
                                .bold()
                            
                            if let uid = auth.user?.uid {
                                Text("Member since \(Date().formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // User Status Badge
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(auth.user?.isAnonymous == true ? Color.orange : Color.green)
                                    .frame(width: 8, height: 8)
                                
                                Text(auth.user?.isAnonymous == true ? "Guest Account" : "Verified User")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 3)

                    // MARK: - Account Actions
                    VStack(spacing: 0) {
                        if auth.user?.isAnonymous == true {
                            VStack(spacing: 16) {
                                Text("Sign in to unlock all features")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                SignInWithAppleButton(.signIn, onRequest: { _ in }, onCompletion: { _ in })
                                    .frame(height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .onTapGesture {
                                        apple.start { result in
                                            switch result {
                                            case .success(let res):
                                                print("Signed in: \(res.user.uid)")
                                            case .failure(let err):
                                                print("Apple sign-in error:", err.localizedDescription)
                                            }
                                        }
                                    }
                            }
                            .padding()
                        } else {
                            Button {
                                auth.signOut()
                                auth.ensureSignedIn()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                    Text("Sign Out")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 2)

                    
                    
                    // MARK: - User Statistics
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your Activity")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        
                        HStack(spacing: 16) {
                            // Friends Count
                            VStack(spacing: 8) {
                                Text("0")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.blue)
                                Text("Friends")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Check-ins Count
                            VStack(spacing: 8) {
                                Text("0")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.green)
                                Text("Check-ins")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Reviews Count
                            VStack(spacing: 8) {
                                Text("0")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.yellow)
                                Text("Reviews")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showMenu = true
                    } label: {
                        VStack(spacing: 3) {
                            Rectangle()
                                .fill(Color.primary)
                                .frame(width: 20, height: 2)
                            Rectangle()
                                .fill(Color.primary)
                                .frame(width: 20, height: 2)
                            Rectangle()
                                .fill(Color.primary)
                                .frame(width: 20, height: 2)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showProfileSetup) {
            ProfileSetupView()
        }
                    .sheet(isPresented: $showAddFriends) {
                AddFriendsView(socialService: FirestoreSocialService())
            }
            .overlay(
                Group {
                    if showMenu {
                        ProfileMenuView(
                            showProfileSetup: $showProfileSetup,
                            showAddFriends: $showAddFriends,
                            isVisible: $showMenu, createTestData: createTestData
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        .ignoresSafeArea()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showMenu)
            )
        }
    
    private func createTestData() {
        Task {
            do {
                let socialService = FirestoreSocialService()
                try await socialService.createTestUsers()
                
                await MainActor.run {
                    // Show success message
                    print("✅ Test data created successfully!")
                }
            } catch {
                print("❌ Error creating test data: \(error)")
            }
        }
    }
}



