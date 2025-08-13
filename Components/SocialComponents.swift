//
//  SocialComponents.swift
//  prestigo
//
//  Created by Berk on 8.08.2025.
//

import SwiftUI

// MARK: - User Avatar
struct UserAvatar: View {
    let photoURL: String?
    let displayName: String
    let size: CGFloat
    let isVerified: Bool
    
    init(photoURL: String?, displayName: String, size: CGFloat = 40, isVerified: Bool = false) {
        self.photoURL = photoURL
        self.displayName = displayName
        self.size = size
        self.isVerified = isVerified
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let photoURL = photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    placeholderView
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                placeholderView
            }
            
            if isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: size * 0.3))
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray4))
            
            Text(displayName.prefix(1).uppercased())
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    let activity: SocialActivity
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    
    @State private var isLiked = false
    @State private var showComments = false
    
    // Get user profile for display
    private var userProfile: UserProfile? {
        DemoSocialData.sampleUserProfiles.first { $0.id == activity.userId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                UserAvatar(
                    photoURL: userProfile?.photoURL,
                    displayName: userProfile?.displayName ?? "Unknown User",
                    size: 40,
                    isVerified: userProfile?.isVerified ?? false
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userProfile?.displayName ?? "Unknown User")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: activity.type.icon)
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(activity.type.displayText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let venueName = activity.venueName {
                            Text("at \(venueName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Text(activity.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Content
            if let content = activity.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            // Photos
            if let photos = activity.photos, !photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(photos, id: \.self) { photoURL in
                            if let url = URL(string: photoURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Interaction Bar
            HStack(spacing: 20) {
                Button(action: {
                    isLiked.toggle()
                    onLike()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .primary)
                        
                        Text("\(activity.likes)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showComments.toggle()
                    onComment()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.primary)
                        
                        Text("\(activity.comments)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showComments) {
            CommentsView(activityId: activity.id ?? "")
        }
    }
}

// MARK: - Comments View
struct CommentsView: View {
    let activityId: String
    @State private var comments: [Comment] = []
    @State private var newComment = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                        .padding()
                } else if comments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No comments yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Be the first to comment!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(comments) { comment in
                        CommentRow(comment: comment)
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Comment input
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Post") {
                        // TODO: Implement comment posting
                        newComment = ""
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
        }
        .onAppear {
            loadComments()
        }
    }
    
    private func loadComments() {
        // For demo purposes, load sample comments
        // TODO: Replace with actual SocialService call when ready
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.comments = DemoSocialData.sampleComments
            self.isLoading = false
        }
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            UserAvatar(
                photoURL: comment.userPhotoURL,
                displayName: comment.userDisplayName,
                size: 32
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.userDisplayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(comment.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(comment.content)
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    Button("Like") {
                        // TODO: Implement like functionality
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Button("Reply") {
                        // TODO: Implement reply functionality
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Friend Request Card
struct FriendRequestCard: View {
    let user: UserProfile
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            UserAvatar(
                photoURL: user.photoURL,
                displayName: user.displayName,
                size: 50,
                isVerified: user.isVerified
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let city = user.city {
                    Text(city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("\(user.prestigePoints) prestige points")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("Accept") {
                    onAccept()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Decline") {
                    onDecline()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                ChatButton(user: user) {
                    // TODO: Navigate to chat
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
