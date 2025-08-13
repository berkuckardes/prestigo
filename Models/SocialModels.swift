//
//  SocialModels.swift
//  prestigo
//
//  Created by Berk on 8.08.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth // Added for Auth.auth().currentUser?.uid

// MARK: - User Profile
struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    let displayName: String
    let photoURL: String?
    let bio: String?
    let city: String?
    let prestigePoints: Int
    let memberSince: Date
    let lastActive: Date
    let isVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case photoURL
        case bio
        case city
        case prestigePoints
        case memberSince
        case lastActive
        case isVerified
    }
}

// MARK: - Friend Relationship
struct FriendRelationship: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let friendId: String
    let status: FriendStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum FriendStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case accepted = "accepted"
        case blocked = "blocked"
        
        var displayText: String {
            switch self {
            case .pending: return "Pending"
            case .accepted: return "Friends"
            case .blocked: return "Blocked"
            }
        }
    }
}

// MARK: - Check-in
struct CheckIn: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let venueId: String
    let venueName: String
    let venueCategory: String
    let checkInTime: Date
    let partySize: Int?
    let caption: String?
    let photos: [String]? // URLs
    let isPublic: Bool
    let likes: Int
    let createdAt: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: checkInTime, relativeTo: Date())
    }
}

// MARK: - Review
struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let venueId: String
    let venueName: String
    let rating: Int // 1-5 stars
    let reviewText: String
    let photos: [String]? // URLs
    let isPublic: Bool
    let likes: Int
    let createdAt: Date
    let updatedAt: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Social Activity
struct SocialActivity: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let type: ActivityType
    let venueId: String?
    let venueName: String?
    let content: String?
    let photos: [String]?
    let likes: Int
    let comments: Int
    let createdAt: Date
    
    enum ActivityType: String, Codable, CaseIterable {
        case checkIn = "check_in"
        case review = "review"
        case booking = "booking"
        case achievement = "achievement"
        
        var displayText: String {
            switch self {
            case .checkIn: return "checked in"
            case .review: return "reviewed"
            case .booking: return "booked"
            case .achievement: return "achieved"
            }
        }
        
        var icon: String {
            switch self {
            case .checkIn: return "mappin.circle.fill"
            case .review: return "star.fill"
            case .booking: return "calendar.badge.plus"
            case .achievement: return "trophy.fill"
            }
        }
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Comment
struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userDisplayName: String
    let userPhotoURL: String?
    let content: String
    let likes: Int
    let createdAt: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Like
struct Like: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let targetId: String // ID of the item being liked (check-in, review, etc.)
    let targetType: String // "check_in", "review", etc.
    let createdAt: Date
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let type: AchievementType
    let title: String
    let description: String
    let icon: String
    let points: Int
    let unlockedAt: Date
    
    enum AchievementType: String, Codable, CaseIterable {
        case firstCheckIn = "first_check_in"
        case firstReview = "first_review"
        case firstBooking = "first_booking"
        case venueExplorer = "venue_explorer"
        case socialButterfly = "social_butterfly"
        case prestigeCollector = "prestige_collector"
        
        var displayText: String {
            switch self {
            case .firstCheckIn: return "First Check-in"
            case .firstReview: return "First Review"
            case .firstBooking: return "First Booking"
            case .venueExplorer: return "Venue Explorer"
            case .socialButterfly: return "Social Butterfly"
            case .prestigeCollector: return "Prestige Collector"
            }
        }
    }
}

// MARK: - Chat Models
struct ChatRoom: Identifiable, Codable {
    @DocumentID var id: String?
    let participants: [String] // User IDs
    let lastMessage: ChatMessage?
    let lastMessageTime: Date?
    let createdAt: Date
    let updatedAt: Date
    
    var otherParticipantId: String? {
        // For 1-on-1 chats, return the other user's ID
        guard let currentUserId = Auth.auth().currentUser?.uid else { return nil }
        return participants.first { $0 != currentUserId }
    }
}

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let content: String
    let messageType: MessageType
    let timestamp: Date
    let isRead: Bool
    let replyTo: String? // ID of message being replied to
    
    enum MessageType: String, Codable, CaseIterable {
        case text = "text"
        case image = "image"
        case venue = "venue" // Share venue information
        case checkIn = "check_in" // Share check-in
        case review = "review" // Share review
        
        var displayText: String {
            switch self {
            case .text: return "Text"
            case .image: return "Image"
            case .venue: return "Venue"
            case .checkIn: return "Check-in"
            case .review: return "Review"
            }
        }
        
        var icon: String {
            switch self {
            case .text: return "text.bubble"
            case .image: return "photo"
            case .venue: return "mappin.circle"
            case .checkIn: return "mappin.circle.fill"
            case .review: return "star.fill"
            }
        }
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct ChatPreview: Identifiable {
    let id: String
    let otherUser: UserProfile
    let lastMessage: ChatMessage?
    let unreadCount: Int
    let lastMessageTime: Date?
    
    var timeDisplay: String {
        guard let lastMessageTime = lastMessageTime else { return "" }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(lastMessageTime) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: lastMessageTime)
        } else if calendar.isDateInYesterday(lastMessageTime) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: lastMessageTime)
        }
    }
}

