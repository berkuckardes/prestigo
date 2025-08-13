//
//  SocialService.swift
//  prestigo
//
//  Created by Berk on 8.08.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol SocialService {
    func getFriendsFeed() async throws -> [SocialActivity]
    func getFriends() async throws -> [UserProfile]
    func getPendingFriendRequests() async throws -> [UserProfile]
    func sendFriendRequest(to userId: String) async throws
    func acceptFriendRequest(from userId: String) async throws
    func declineFriendRequest(from userId: String) async throws
    func removeFriend(userId: String) async throws
    func createCheckIn(venueId: String, venueName: String, venueCategory: String, caption: String?, photos: [String]?, partySize: Int?) async throws
    func createReview(venueId: String, venueName: String, rating: Int, reviewText: String, photos: [String]?) async throws
    func likeActivity(activityId: String, activityType: String) async throws
    func unlikeActivity(activityId: String, activityType: String) async throws
    func addComment(to activityId: String, content: String) async throws
    func getComments(for activityId: String) async throws -> [Comment]
    
    // Chat functionality
    func getChatRooms() async throws -> [ChatRoom]
    func getChatMessages(for chatRoomId: String) async throws -> [ChatMessage]
    func sendMessage(to chatRoomId: String, content: String, messageType: ChatMessage.MessageType) async throws
    func markMessageAsRead(messageId: String) async throws
    func createChatRoom(with userId: String) async throws -> String
    func getChatPreview() async throws -> [ChatPreview]
}

final class FirestoreSocialService: SocialService, ObservableObject {
    @Published var friendsFeed: [SocialActivity] = []
    @Published var friends: [UserProfile] = []
    @Published var pendingRequests: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    // MARK: - Friends Feed
    func getFriendsFeed() async throws -> [SocialActivity] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        // For demo purposes, return sample data
        // TODO: Replace with actual Firestore queries when ready
        let activities = DemoSocialData.sampleSocialActivities
        
        await MainActor.run {
            self.friendsFeed = activities
        }
        
        return activities
    }
    
    private func getSocialActivities(for userId: String) async throws -> [SocialActivity] {
        let snapshot = try await db.collection("social_activities")
            .whereField("userId", isEqualTo: userId)
            .whereField("isPublic", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: SocialActivity.self)
        }
    }
    
    // MARK: - Friends Management
    func getFriends() async throws -> [UserProfile] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        // For demo purposes, return sample data
        // TODO: Replace with actual Firestore queries when ready
        let friends = DemoSocialData.sampleUserProfiles
        
        await MainActor.run {
            self.friends = friends
        }
        
        return friends
    }
    
    func getPendingFriendRequests() async throws -> [UserProfile] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        // For demo purposes, return sample data
        // TODO: Replace with actual Firestore queries when ready
        let pendingRequests = Array(DemoSocialData.sampleUserProfiles.prefix(2)) // Show first 2 as pending
        
        await MainActor.run {
            self.pendingRequests = pendingRequests
        }
        
        return pendingRequests
    }
    
    func sendFriendRequest(to userId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        guard currentUserId != userId else {
            throw SocialError.cannotAddSelf
        }
        
        // Check if relationship already exists
        let existingSnapshot = try await db.collection("friend_relationships")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("friendId", isEqualTo: userId)
            .getDocuments()
        
        if !existingSnapshot.documents.isEmpty {
            throw SocialError.relationshipAlreadyExists
        }
        
        let relationship = FriendRelationship(
            userId: currentUserId,
            friendId: userId,
            status: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await db.collection("friend_relationships").addDocument(from: relationship)
    }
    
    func acceptFriendRequest(from userId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        // Update the pending request to accepted
        let snapshot = try await db.collection("friend_relationships")
            .whereField("userId", isEqualTo: userId)
            .whereField("friendId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: FriendRelationship.FriendStatus.pending.rawValue)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw SocialError.relationshipNotFound
        }
        
        try await document.reference.updateData([
            "status": FriendRelationship.FriendStatus.accepted.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
        
        // Create reciprocal relationship
        let reciprocalRelationship = FriendRelationship(
            userId: currentUserId,
            friendId: userId,
            status: .accepted,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await db.collection("friend_relationships").addDocument(from: reciprocalRelationship)
        
        // Refresh friends list
        _ = try await getFriends()
        _ = try await getPendingFriendRequests()
    }
    
    func declineFriendRequest(from userId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection("friend_relationships")
            .whereField("userId", isEqualTo: userId)
            .whereField("friendId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: FriendRelationship.FriendStatus.pending.rawValue)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw SocialError.relationshipNotFound
        }
        
        try await document.reference.delete()
        
        // Refresh pending requests
        _ = try await getPendingFriendRequests()
    }
    
    func removeFriend(userId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        // Delete both relationships
        let batch = db.batch()
        
        let userToFriend = try await db.collection("friend_relationships")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("friendId", isEqualTo: userId)
            .getDocuments()
        
        let friendToUser = try await db.collection("friend_relationships")
            .whereField("userId", isEqualTo: userId)
            .whereField("friendId", isEqualTo: currentUserId)
            .getDocuments()
        
        userToFriend.documents.forEach { doc in
            batch.deleteDocument(doc.reference)
        }
        
        friendToUser.documents.forEach { doc in
            batch.deleteDocument(doc.reference)
        }
        
        try await batch.commit()
        
        // Refresh friends list
        _ = try await getFriends()
    }
    
    // MARK: - Social Activities
    func createCheckIn(venueId: String, venueName: String, venueCategory: String, caption: String?, photos: [String]?, partySize: Int?) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        let checkIn = CheckIn(
            userId: currentUserId,
            venueId: venueId,
            venueName: venueName,
            venueCategory: venueCategory,
            checkInTime: Date(),
            partySize: partySize,
            caption: caption,
            photos: photos,
            isPublic: true,
            likes: 0,
            createdAt: Date()
        )
        
        try await db.collection("check_ins").addDocument(from: checkIn)
        
        // Create social activity
        let activity = SocialActivity(
            userId: currentUserId,
            type: .checkIn,
            venueId: venueId,
            venueName: venueName,
            content: caption,
            photos: photos,
            likes: 0,
            comments: 0,
            createdAt: Date()
        )
        
        try await db.collection("social_activities").addDocument(from: activity)
        
        // Refresh feed
        _ = try await getFriendsFeed()
    }
    
    func createReview(venueId: String, venueName: String, rating: Int, reviewText: String, photos: [String]?) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        let review = Review(
            userId: currentUserId,
            venueId: venueId,
            venueName: venueName,
            rating: rating,
            reviewText: reviewText,
            photos: photos,
            isPublic: true,
            likes: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await db.collection("reviews").addDocument(from: review)
        
        // Create social activity
        let activity = SocialActivity(
            userId: currentUserId,
            type: .review,
            venueId: venueId,
            venueName: venueName,
            content: reviewText,
            photos: photos,
            likes: 0,
            comments: 0,
            createdAt: Date()
        )
        
        try await db.collection("social_activities").addDocument(from: activity)
        
        // Refresh feed
        _ = try await getFriendsFeed()
    }
    
    // MARK: - Interactions
    func likeActivity(activityId: String, activityType: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        let like = Like(
            userId: currentUserId,
            targetId: activityId,
            targetType: activityType,
            createdAt: Date()
        )
        
        try await db.collection("likes").addDocument(from: like)
        
        // Update like count
        let collectionName = activityType == "check_in" ? "check_ins" : 
                           activityType == "review" ? "reviews" : "social_activities"
        
        let snapshot = try await db.collection(collectionName)
            .whereField("id", isEqualTo: activityId)
            .getDocuments()
        
        if let document = snapshot.documents.first {
            try await document.reference.updateData([
                "likes": FieldValue.increment(Int64(1))
            ])
        }
    }
    
    func unlikeActivity(activityId: String, activityType: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        // Find and delete the like
        let snapshot = try await db.collection("likes")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("targetId", isEqualTo: activityId)
            .whereField("targetType", isEqualTo: activityType)
            .getDocuments()
        
        if let document = snapshot.documents.first {
            try await document.reference.delete()
            
            // Update like count
            let collectionName = activityType == "check_in" ? "check_ins" : 
                               activityType == "review" ? "reviews" : "social_activities"
            
            let activitySnapshot = try await db.collection(collectionName)
                .whereField("id", isEqualTo: activityId)
                .getDocuments()
            
            if let activityDoc = activitySnapshot.documents.first {
                try await activityDoc.reference.updateData([
                    "likes": FieldValue.increment(Int64(-1))
                ])
            }
        }
    }
    
    func addComment(to activityId: String, content: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        let user = Auth.auth().currentUser
        let comment = Comment(
            userId: currentUserId,
            userDisplayName: user?.displayName ?? "Guest",
            userPhotoURL: user?.photoURL?.absoluteString,
            content: content,
            likes: 0,
            createdAt: Date()
        )
        
        try await db.collection("comments").addDocument(from: comment)
        
        // Update comment count
        let snapshot = try await db.collection("social_activities")
            .whereField("id", isEqualTo: activityId)
            .getDocuments()
        
        if let document = snapshot.documents.first {
            try await document.reference.updateData([
                "comments": FieldValue.increment(Int64(1))
            ])
        }
    }
    
    func getComments(for activityId: String) async throws -> [Comment] {
        let snapshot = try await db.collection("comments")
            .whereField("targetId", isEqualTo: activityId)
            .order(by: "createdAt", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Comment.self)
        }
    }
    
    // MARK: - Helper Methods
    private func getUserProfile(userId: String) async throws -> UserProfile? {
        let document = try await db.collection("users").document(userId).getDocument()
        return try? document.data(as: UserProfile.self)
    }
    
    // MARK: - Chat Functionality
    func getChatRooms() async throws -> [ChatRoom] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection("chat_rooms")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "updatedAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ChatRoom.self)
        }
    }
    
    func getChatMessages(for chatRoomId: String) async throws -> [ChatMessage] {
        let snapshot = try await db.collection("chat_rooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .limit(to: 50)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ChatMessage.self)
        }
    }
    
    func sendMessage(to chatRoomId: String, content: String, messageType: ChatMessage.MessageType) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        let message = ChatMessage(
            senderId: currentUserId,
            content: content,
            messageType: messageType,
            timestamp: Date(),
            isRead: false,
            replyTo: nil
        )
        
        // Add message to chat room
        try await db.collection("chat_rooms")
            .document(chatRoomId)
            .collection("messages")
            .addDocument(from: message)
        
        // Update chat room with last message info
        try await db.collection("chat_rooms")
            .document(chatRoomId)
            .updateData([
                "lastMessage": try Firestore.Encoder().encode(message),
                "lastMessageTime": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ])
    }
    
    func markMessageAsRead(messageId: String) async throws {
        // This would require finding the message in the appropriate chat room
        // For now, we'll implement a simplified version
        print("Marking message as read: \(messageId)")
    }
    
    func createChatRoom(with userId: String) async throws -> String {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw SocialError.userNotAuthenticated
        }
        
        // Check if chat room already exists
        let existingSnapshot = try await db.collection("chat_rooms")
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments()
        
        for doc in existingSnapshot.documents {
            if let chatRoom = try? doc.data(as: ChatRoom.self),
               chatRoom.participants.contains(userId) {
                return doc.documentID
            }
        }
        
        // Create new chat room
        let chatRoom = ChatRoom(
            participants: [currentUserId, userId],
            lastMessage: nil,
            lastMessageTime: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let docRef = try await db.collection("chat_rooms").addDocument(from: chatRoom)
        return docRef.documentID
    }
    
    func getChatPreview() async throws -> [ChatPreview] {
        // For demo purposes, return sample data
        // TODO: Replace with actual Firestore queries when ready
        let chatPreviews = DemoSocialData.sampleChatPreviews
        
        return chatPreviews
    }
}

// MARK: - Errors
enum SocialError: LocalizedError {
    case userNotAuthenticated
    case relationshipAlreadyExists
    case relationshipNotFound
    case cannotAddSelf
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User not authenticated"
        case .relationshipAlreadyExists:
            return "Friend relationship already exists"
        case .relationshipNotFound:
            return "Friend relationship not found"
        case .cannotAddSelf:
            return "Cannot add yourself as a friend"
        case .invalidData:
            return "Invalid data provided"
        }
    }
}
