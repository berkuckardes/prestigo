//
//  FriendsFeedView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//

import SwiftUI

struct FriendsFeedView: View {
    @StateObject private var socialService = FirestoreSocialService()
    @State private var selectedTab = 0
    @State private var showAddFriends = false
    @State private var showCheckIn = false
    @State private var showReview = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Picker
                Picker("", selection: $selectedTab) {
                    Text("Feed").tag(0)
                    Text("Friends").tag(1)
                    Text("Requests").tag(2)
                    Text("Chats").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Friends Feed Tab
                    FriendsFeedTab(socialService: socialService, onShowAddFriends: { showAddFriends = true })
                        .tag(0)
                    
                    // Friends List Tab
                    FriendsListTab(socialService: socialService, onShowAddFriends: { showAddFriends = true })
                        .tag(1)
                    
                    // Friend Requests Tab
                    FriendRequestsTab(socialService: socialService, onShowAddFriends: { showAddFriends = true })
                        .tag(2)
                    
                    // Chats Tab
                    ChatListView(socialService: socialService, onShowAddFriends: { showAddFriends = true })
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Friends") {
                            showAddFriends = true
                        }
                        
                        Button("Check In") {
                            showCheckIn = true
                        }
                        
                        Button("Write Review") {
                            showReview = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            .onAppear {
                Task {
                    await refreshData()
                }
            }
            .sheet(isPresented: $showAddFriends) {
                AddFriendsView(socialService: socialService)
            }
            .sheet(isPresented: $showCheckIn) {
                CheckInView(socialService: socialService)
            }
            .sheet(isPresented: $showReview) {
                ReviewView(socialService: socialService)
            }
        }
    }
    
    private func refreshData() async {
        do {
            try await socialService.getFriendsFeed()
            try await socialService.getFriends()
            try await socialService.getPendingFriendRequests()
        } catch {
            print("Error refreshing data: \(error)")
        }
    }
}

// MARK: - Friends Feed Tab
struct FriendsFeedTab: View {
    @ObservedObject var socialService: FirestoreSocialService
    let onShowAddFriends: () -> Void
    @State private var userProfiles: [String: UserProfile] = [:]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if socialService.isLoading {
                    LoadingView(message: "Loading friends' activities...")
                        .frame(height: 200)
                } else if socialService.friendsFeed.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Activities Yet",
                        message: "When your friends check in to venues or write reviews, they'll appear here.",
                        actionTitle: "Find Friends",
                        action: onShowAddFriends
                    )
                    .frame(height: 400)
                } else {
                    ForEach(socialService.friendsFeed) { activity in
                        ActivityCard(
                            activity: activity,
                            userProfile: userProfiles[activity.userId],
                            onLike: {
                                Task {
                                    try await socialService.likeActivity(
                                        activityId: activity.id ?? "",
                                        activityType: activity.type.rawValue
                                    )
                                }
                            },
                            onComment: {
                                // Comments are handled in ActivityCard
                            },
                            onShare: {
                                // TODO: Implement share functionality
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // Account for tab bar
        }
        .onAppear {
            loadUserProfiles()
        }
        .onChange(of: socialService.friendsFeed) { _ in
            loadUserProfiles()
        }
    }
    
    private func loadUserProfiles() {
        Task {
            do {
                let userIds = Array(Set(socialService.friendsFeed.map { $0.userId }))
                let profiles = try await socialService.getUserProfiles(userIds: userIds)
                
                await MainActor.run {
                    var profileDict: [String: UserProfile] = [:]
                    for profile in profiles {
                        if let id = profile.id {
                            profileDict[id] = profile
                        }
                    }
                    self.userProfiles = profileDict
                }
            } catch {
                print("Error loading user profiles: \(error)")
            }
        }
    }
}

// MARK: - Friends List Tab
struct FriendsListTab: View {
    @ObservedObject var socialService: FirestoreSocialService
    let onShowAddFriends: () -> Void
    @State private var searchText = ""
    
    var filteredFriends: [UserProfile] {
        if searchText.isEmpty {
            return socialService.friends
        } else {
            return socialService.friends.filter { friend in
                friend.displayName.localizedCaseInsensitiveContains(searchText) ||
                (friend.city?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search friends...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            if socialService.isLoading {
                LoadingView(message: "Loading friends...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredFriends.isEmpty {
                if searchText.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Friends Yet",
                        message: "Start connecting with people to see their activities and share your experiences.",
                        actionTitle: "Add Friends",
                        action: onShowAddFriends
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No friends found matching '\(searchText)'",
                        actionTitle: nil,
                        action: nil
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                List(filteredFriends) { friend in
                    FriendRow(friend: friend) {
                        // TODO: Navigate to friend profile
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: - Friend Row
struct FriendRow: View {
    let friend: UserProfile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                UserAvatar(
                    photoURL: friend.photoURL,
                    displayName: friend.displayName,
                    size: 50,
                    isVerified: friend.isVerified
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let city = friend.city {
                        Text(city)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Text("\(friend.prestigePoints) prestige points")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Member since \(friend.memberSince.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    ChatButton(user: friend) {
                        // TODO: Navigate to chat
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Friend Requests Tab
struct FriendRequestsTab: View {
    @ObservedObject var socialService: FirestoreSocialService
    let onShowAddFriends: () -> Void
    @State private var outgoingRequests: [UserProfile] = []
    @State private var showOutgoing = false
    
    var body: some View {
        VStack {
            if socialService.isLoading {
                LoadingView(message: "Loading friend requests...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if socialService.pendingRequests.isEmpty && outgoingRequests.isEmpty {
                EmptyStateView(
                    icon: "person.badge.plus",
                    title: "No Friend Requests",
                    message: "You don't have any pending friend requests at the moment.",
                    actionTitle: "Add Friends",
                    action: onShowAddFriends
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 16) {
                    // Incoming Requests
                    if !socialService.pendingRequests.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Incoming Requests")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(socialService.pendingRequests) { user in
                                        FriendRequestCard(
                                            user: user,
                                            onAccept: {
                                                Task {
                                                    try await socialService.acceptFriendRequest(from: user.id ?? "")
                                                }
                                            },
                                            onDecline: {
                                                Task {
                                                    try await socialService.declineFriendRequest(from: user.id ?? "")
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // Outgoing Requests
                    if !outgoingRequests.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Outgoing Requests")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(outgoingRequests) { user in
                                        HStack {
                                            UserAvatar(
                                                photoURL: user.photoURL,
                                                displayName: user.displayName,
                                                size: 50,
                                                isVerified: user.isVerified
                                            )
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(user.displayName)
                                                    .font(.headline)
                                                
                                                if let city = user.city {
                                                    Text(city)
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                                
                                                Text("Request sent")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Button("Cancel") {
                                                cancelOutgoingRequest(to: user.id ?? "")
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .controlSize(.small)
                                            .tint(.orange)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            loadOutgoingRequests()
        }
    }
    
    private func loadOutgoingRequests() {
        Task {
            do {
                let outgoing = try await socialService.getOutgoingFriendRequests()
                await MainActor.run {
                    self.outgoingRequests = outgoing
                }
            } catch {
                print("Error loading outgoing requests: \(error)")
            }
        }
    }
    
    private func cancelOutgoingRequest(to userId: String) {
        Task {
            do {
                try await socialService.cancelOutgoingRequest(to: userId)
                await MainActor.run {
                    loadOutgoingRequests()
                }
            } catch {
                print("Error canceling outgoing request: \(error)")
            }
        }
    }
}







#Preview {
    FriendsFeedView()
        .environmentObject(AuthService())
}
