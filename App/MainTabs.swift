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
    @State private var selection: Tab = .explore
    
    init() {
        // Make Tab Bar opaque
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selection) {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "magnifyingglass") }
                .tag(Tab.explore)

            BookingsView(selectedTab: $selection)
                .tabItem { Label("Bookings", systemImage: "calendar") }
                .tag(Tab.bookings)

            FriendsFeedView()
                .tabItem { Label("Friends", systemImage: "person.2") }
                .tag(Tab.friends)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
                .tag(Tab.profile)
        }
    }
}
