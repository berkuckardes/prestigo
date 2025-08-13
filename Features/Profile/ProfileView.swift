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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Profile Card
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)

                        Text(auth.user?.displayName ?? "Guest")
                            .font(.title2)
                            .bold()

                        if let uid = auth.user?.uid {
                            Text("UID: \(uid)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 2)

                    // MARK: - Account Actions
                    VStack(spacing: 0) {
                        if auth.user?.isAnonymous == true {
                            SignInWithAppleButton(.signIn, onRequest: { _ in }, onCompletion: { _ in })
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 1)

                    // MARK: - Extra Settings / Info
                    VStack(spacing: 0) {
                        Button {
                            print("View Booking History tapped")
                        } label: {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text("Booking History")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }

                        Divider()

                        Button {
                            print("Edit Profile tapped")
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.green)
                                Text("Edit Profile")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 1)
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}



