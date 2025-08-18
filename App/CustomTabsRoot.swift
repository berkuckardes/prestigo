//
//  CustomTabsRoot.swift
//  prestigo
//
//  Created by Berk  on 12.08.2025.
//
// App/CustomTabsRoot.swift
import SwiftUI

struct CustomTabsRoot: View {
    @State private var selection: Tab = .explore

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .explore:  ExploreView()
                case .bookings: BookingsView()
                case .friends:  FriendsFeedView()
                case .profile:  ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)

            CustomTabBar(selection: $selection)
                .padding(.horizontal, 20)
                .padding(.bottom, 0)
        }
    }
}

