//
//  MainTabs.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
//
//  MainTabs.swift
//  prestigo
//
//  Created by Berk on 8.08.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MainTabs: View {
    init() {
        // Make Tab Bar opaque
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "magnifyingglass") }

            BookingsView()
                .tabItem { Label("Bookings", systemImage: "calendar") }

            FriendsFeedView()
                .tabItem { Label("Friends", systemImage: "person.2") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

struct BookingsView: View {
    @State private var reservations: [Reservation] = []
    @State private var loading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView("Loading bookings...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if reservations.isEmpty {
                    Text("No reservations found.")
                        .foregroundColor(.secondary)
                } else {
                    List(reservations) { res in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(res.venueName)
                                .font(.headline)
                            Text("\(res.slotStart.formatted(date: .abbreviated, time: .shortened)) – \(res.slotEnd.formatted(date: .omitted, time: .shortened))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listStyle(.plain)
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle("Bookings")
            .onAppear {
                fetchReservations()
            }
        }
    }

    private func fetchReservations() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user signed in"
            self.loading = false
            return
        }

        Firestore.firestore()
            .collection("reservations")
            .whereField("userId", isEqualTo: uid)
            .order(by: "slotStart", descending: false)
            .addSnapshotListener { snapshot, error in
                loading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.reservations = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Reservation.self)
                } ?? []
            }
    }
}

// Firestore model
struct Reservation: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var venueId: String
    var venueName: String
    var slotId: String
    var slotStart: Date
    var slotEnd: Date
    var partySize: Int
    var status: String
}
