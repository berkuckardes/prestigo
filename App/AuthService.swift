//
//  AuthService.swift
//  prestigo
//
//  Created by Berk  on 12.08.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService: ObservableObject {
    @Published var user: User?
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    func ensureSignedIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error { 
                    print("Anonymous sign-in failed:", error)
                    return 
                }
                if let user = result?.user {
                    self.user = user
                    self.upsertUserDoc(user)
                    print("Signed in anonymously:", user.uid)
                }
            }
        } else {
            self.user = Auth.auth().currentUser
            if let u = self.user { 
                self.upsertUserDoc(u) 
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Sign out failed:", error)
        }
    }
    
    private func upsertUserDoc(_ user: User) {
        let db = Firestore.firestore()
        let displayName = user.displayName?.isEmpty == false ? user.displayName! : "Guest \(user.uid.prefix(6))"
        let data: [String: Any] = [
            "displayName": displayName,
            "photoURL": user.photoURL?.absoluteString ?? "",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        db.collection("users").document(user.uid).setData(data, merge: true)
    }
    
    // Create a complete user profile
    func createUserProfile(displayName: String, bio: String? = nil, city: String? = nil) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }
        
        let db = Firestore.firestore()
        let userProfile = UserProfile(
            id: currentUser.uid,
            displayName: displayName,
            photoURL: currentUser.photoURL?.absoluteString,
            bio: bio,
            city: city,
            prestigePoints: 0,
            memberSince: Date(),
            lastActive: Date(),
            isVerified: false
        )
        
        try await db.collection("users").document(currentUser.uid).setData(from: userProfile)
    }
}

