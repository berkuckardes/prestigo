//
//  ChatComponents.swift
//  prestigo
//
//  Created by Berk on 8.08.2025.
//

import SwiftUI
import FirebaseAuth

// MARK: - Chat List View
struct ChatListView: View {
    @ObservedObject var socialService: FirestoreSocialService
    let onShowAddFriends: () -> Void
    @State private var chatPreviews: [ChatPreview] = []
    @State private var isLoading = false
    @State private var searchText = ""
    
    var filteredChats: [ChatPreview] {
        if searchText.isEmpty {
            return chatPreviews
        } else {
            return chatPreviews.filter { chat in
                chat.otherUser.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search chats...", text: $searchText)
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
            
            if isLoading {
                LoadingView(message: "Loading chats...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredChats.isEmpty {
                if searchText.isEmpty {
                    EmptyStateView(
                        icon: "message",
                        title: "No Chats Yet",
                        message: "Start conversations with your friends to share venue experiences and recommendations.",
                        actionTitle: "Find Friends",
                        action: onShowAddFriends
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No chats found matching '\(searchText)'",
                        actionTitle: nil,
                        action: nil
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                List(filteredChats) { chatPreview in
                    ChatPreviewRow(chatPreview: chatPreview) {
                        // TODO: Navigate to chat
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            loadChatPreviews()
        }
    }
    
    private func loadChatPreviews() {
        isLoading = true
        
        Task {
            do {
                let previews = try await socialService.getChatPreview()
                await MainActor.run {
                    self.chatPreviews = previews
                    self.isLoading = false
                }
            } catch {
                print("Error loading chat previews: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Chat Preview Row
struct ChatPreviewRow: View {
    let chatPreview: ChatPreview
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                UserAvatar(
                    photoURL: chatPreview.otherUser.photoURL,
                    displayName: chatPreview.otherUser.displayName,
                    size: 50,
                    isVerified: chatPreview.otherUser.isVerified
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chatPreview.otherUser.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(chatPreview.timeDisplay)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastMessage = chatPreview.lastMessage {
                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("No messages yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    if chatPreview.unreadCount > 0 {
                        Text("\(chatPreview.unreadCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
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

// MARK: - Chat View
struct ChatView: View {
    let chatRoomId: String
    let otherUser: UserProfile
    @ObservedObject var socialService: FirestoreSocialService
    
    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var isLoading = false
    @State private var showImagePicker = false
    @State private var showVenuePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            chatMessagesView
            messageInputView
        }
        .navigationTitle(otherUser.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadMessages()
        }
        .sheet(isPresented: $showImagePicker) {
            // TODO: Implement image picker
            Text("Image Picker - Coming Soon!")
        }
        .sheet(isPresented: $showVenuePicker) {
            // TODO: Implement venue picker
            Text("Venue Picker - Coming Soon!")
        }
    }
    
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if isLoading {
                        LoadingView(message: "Loading messages...")
                            .frame(height: 100)
                    } else if messages.isEmpty {
                        EmptyStateView(
                            icon: "message",
                            title: "No Messages Yet",
                            message: "Start the conversation by sending a message!",
                            actionTitle: nil,
                            action: nil
                        )
                        .frame(height: 200)
                    } else {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == Auth.auth().currentUser?.uid
                            )
                            .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Attachment button
                Menu {
                    Button("Photo") {
                        showImagePicker = true
                    }
                    
                    Button("Venue") {
                        showVenuePicker = true
                    }
                    
                    Button("Check-in") {
                        // TODO: Share check-in
                    }
                    
                    Button("Review") {
                        // TODO: Share review
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                // Message input field
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        sendMessage()
                    }
                
                // Send button
                Button("Send") {
                    sendMessage()
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private func loadMessages() {
        isLoading = true
        
        Task {
            do {
                let chatMessages = try await socialService.getChatMessages(for: chatRoomId)
                await MainActor.run {
                    self.messages = chatMessages
                    self.isLoading = false
                }
            } catch {
                print("Error loading messages: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func sendMessage() {
        let messageContent = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageContent.isEmpty else { return }
        
        Task {
            do {
                try await socialService.sendMessage(
                    to: chatRoomId,
                    content: messageContent,
                    messageType: .text
                )
                
                await MainActor.run {
                    newMessage = ""
                    // Reload messages to show the new one
                    loadMessages()
                }
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message content
                VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                    if message.messageType != .text {
                        HStack(spacing: 6) {
                            Image(systemName: message.messageType.icon)
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text(message.messageType.displayText)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(isFromCurrentUser ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                        )
                }
                
                // Timestamp
                Text(message.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - Chat Button
struct ChatButton: View {
    let user: UserProfile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "message")
                    .font(.caption)
                
                Text("Message")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
