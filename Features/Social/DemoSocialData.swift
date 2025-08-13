//
//  DemoSocialData.swift
//  prestigo
//
//  Created by Berk on 8.08.2025.
//

import Foundation

// MARK: - Demo Data for Testing
struct DemoSocialData {
    static let sampleUserProfiles: [UserProfile] = [
        UserProfile(
            id: "user1",
            displayName: "Alex Chen",
            photoURL: nil,
            bio: "Food enthusiast and adventure seeker",
            city: "Istanbul",
            prestigePoints: 1250,
            memberSince: Date().addingTimeInterval(-86400 * 365), // 1 year ago
            lastActive: Date().addingTimeInterval(-3600), // 1 hour ago
            isVerified: true
        ),
        UserProfile(
            id: "user2",
            displayName: "Sarah Johnson",
            photoURL: nil,
            bio: "Luxury lifestyle blogger",
            city: "Istanbul",
            prestigePoints: 890,
            memberSince: Date().addingTimeInterval(-86400 * 180), // 6 months ago
            lastActive: Date().addingTimeInterval(-7200), // 2 hours ago
            isVerified: false
        ),
        UserProfile(
            id: "user3",
            displayName: "Mehmet Yılmaz",
            photoURL: nil,
            bio: "Local foodie and culture lover",
            city: "Istanbul",
            prestigePoints: 2100,
            memberSince: Date().addingTimeInterval(-86400 * 730), // 2 years ago
            lastActive: Date().addingTimeInterval(-1800), // 30 minutes ago
            isVerified: true
        ),
        UserProfile(
            id: "user4",
            displayName: "Emma Wilson",
            photoURL: nil,
            bio: "Travel photographer and restaurant reviewer",
            city: "Istanbul",
            prestigePoints: 750,
            memberSince: Date().addingTimeInterval(-86400 * 90), // 3 months ago
            lastActive: Date().addingTimeInterval(-10800), // 3 hours ago
            isVerified: false
        )
    ]
    
    static let sampleSocialActivities: [SocialActivity] = [
        SocialActivity(
            id: "activity1",
            userId: "user1",
            type: .checkIn,
            venueId: "neo",
            venueName: "Neolokal",
            content: "Amazing dinner experience! The fusion of traditional Turkish and modern cuisine is incredible. 🍽️✨",
            photos: ["https://picsum.photos/seed/neo1/400/300", "https://picsum.photos/seed/neo2/400/300"],
            likes: 12,
            comments: 3,
            createdAt: Date().addingTimeInterval(-3600) // 1 hour ago
        ),
        SocialActivity(
            id: "activity2",
            userId: "user2",
            type: .review,
            venueId: "mikla",
            venueName: "Mikla",
            content: "Absolutely stunning rooftop views and the tasting menu exceeded all expectations. A must-visit for food lovers! ⭐⭐⭐⭐⭐",
            photos: ["https://picsum.photos/seed/mikla1/400/300"],
            likes: 8,
            comments: 2,
            createdAt: Date().addingTimeInterval(-7200) // 2 hours ago
        ),
        SocialActivity(
            id: "activity3",
            userId: "user3",
            type: .checkIn,
            venueId: "tonyguy",
            venueName: "Toni&Guy Nişantaşı",
            content: "Perfect haircut and styling! The team here really knows their craft. 💇‍♂️✂️",
            photos: [],
            likes: 5,
            comments: 1,
            createdAt: Date().addingTimeInterval(-10800) // 3 hours ago
        ),
        SocialActivity(
            id: "activity4",
            userId: "user4",
            type: .review,
            venueId: "neo",
            venueName: "Neolokal",
            content: "The atmosphere and service are top-notch. The wine pairing recommendations were spot on! 🍷",
            photos: ["https://picsum.photos/seed/neo3/400/300"],
            likes: 15,
            comments: 4,
            createdAt: Date().addingTimeInterval(-14400) // 4 hours ago
        ),
        SocialActivity(
            id: "activity5",
            userId: "user1",
            type: .achievement,
            venueId: nil,
            venueName: nil,
            content: "Just unlocked the 'Venue Explorer' achievement! 🏆",
            photos: [],
            likes: 20,
            comments: 6,
            createdAt: Date().addingTimeInterval(-18000) // 5 hours ago
        )
    ]
    
    static let sampleCheckIns: [CheckIn] = [
        CheckIn(
            id: "checkin1",
            userId: "user1",
            venueId: "neo",
            venueName: "Neolokal",
            venueCategory: "restaurant",
            checkInTime: Date().addingTimeInterval(-3600),
            partySize: 4,
            caption: "Amazing dinner experience! The fusion of traditional Turkish and modern cuisine is incredible. 🍽️✨",
            photos: ["https://picsum.photos/seed/neo1/400/300", "https://picsum.photos/seed/neo2/400/300"],
            isPublic: true,
            likes: 12,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        CheckIn(
            id: "checkin2",
            userId: "user3",
            venueId: "tonyguy",
            venueName: "Toni&Guy Nişantaşı",
            venueCategory: "barber",
            checkInTime: Date().addingTimeInterval(-10800),
            partySize: 1,
            caption: "Perfect haircut and styling! The team here really knows their craft. 💇‍♂️✂️",
            photos: [],
            isPublic: true,
            likes: 5,
            createdAt: Date().addingTimeInterval(-10800)
        )
    ]
    
    static let sampleReviews: [Review] = [
        Review(
            id: "review1",
            userId: "user2",
            venueId: "mikla",
            venueName: "Mikla",
            rating: 5,
            reviewText: "Absolutely stunning rooftop views and the tasting menu exceeded all expectations. A must-visit for food lovers! ⭐⭐⭐⭐⭐",
            photos: ["https://picsum.photos/seed/mikla1/400/300"],
            isPublic: true,
            likes: 8,
            createdAt: Date().addingTimeInterval(-7200),
            updatedAt: Date().addingTimeInterval(-7200)
        ),
        Review(
            id: "review2",
            userId: "user4",
            venueId: "neo",
            venueName: "Neolokal",
            rating: 5,
            reviewText: "The atmosphere and service are top-notch. The wine pairing recommendations were spot on! 🍷",
            photos: ["https://picsum.photos/seed/neo3/400/300"],
            isPublic: true,
            likes: 15,
            createdAt: Date().addingTimeInterval(-14400),
            updatedAt: Date().addingTimeInterval(-14400)
        )
    ]
    
    static let sampleComments: [Comment] = [
        Comment(
            id: "comment1",
            userId: "user2",
            userDisplayName: "Sarah Johnson",
            userPhotoURL: nil,
            content: "Looks amazing! I need to try this place soon! 😍",
            likes: 2,
            createdAt: Date().addingTimeInterval(-1800)
        ),
        Comment(
            id: "comment2",
            userId: "user3",
            userDisplayName: "Mehmet Yılmaz",
            userPhotoURL: nil,
            content: "Great choice! Their signature dishes are incredible.",
            likes: 1,
            createdAt: Date().addingTimeInterval(-900)
        ),
        Comment(
            id: "comment3",
            userId: "user4",
            userDisplayName: "Emma Wilson",
            userPhotoURL: nil,
            content: "I've been there too! The service is exceptional.",
            likes: 0,
            createdAt: Date().addingTimeInterval(-600)
        )
    ]
    
    static let sampleAchievements: [Achievement] = [
        Achievement(
            id: "achievement1",
            userId: "user1",
            type: .venueExplorer,
            title: "Venue Explorer",
            description: "Visited 10 different venues",
            icon: "mappin.circle.fill",
            points: 100,
            unlockedAt: Date().addingTimeInterval(-18000)
        ),
        Achievement(
            id: "achievement2",
            userId: "user3",
            type: .prestigeCollector,
            title: "Prestige Collector",
            description: "Earned 2000+ prestige points",
            icon: "trophy.fill",
            points: 250,
            unlockedAt: Date().addingTimeInterval(-86400)
        )
    ]
    
    // MARK: - Demo Chat Data
    static let sampleChatMessages: [ChatMessage] = [
        ChatMessage(
            id: "msg1",
            senderId: "user2",
            content: "Hey! Have you tried that new restaurant downtown?",
            messageType: .text,
            timestamp: Date().addingTimeInterval(-3600),
            isRead: true,
            replyTo: nil
        ),
        ChatMessage(
            id: "msg2",
            senderId: "user1",
            content: "Yes! It's amazing. The food is incredible and the atmosphere is perfect for dates.",
            messageType: .text,
            timestamp: Date().addingTimeInterval(-3300),
            isRead: true,
            replyTo: nil
        ),
        ChatMessage(
            id: "msg3",
            senderId: "user2",
            content: "That sounds perfect! I'm planning a date night this weekend. Any recommendations?",
            messageType: .text,
            timestamp: Date().addingTimeInterval(-3000),
            isRead: false,
            replyTo: nil
        ),
        ChatMessage(
            id: "msg4",
            senderId: "user1",
            content: "Definitely try the tasting menu! And make sure to book a table by the window for the city views.",
            messageType: .text,
            timestamp: Date().addingTimeInterval(-2700),
            isRead: false,
            replyTo: nil
        ),
        ChatMessage(
            id: "msg5",
            senderId: "user2",
            content: "Perfect! Thanks for the tip. I'll let you know how it goes! 😊",
            messageType: .text,
            timestamp: Date().addingTimeInterval(-2400),
            isRead: false,
            replyTo: nil
        )
    ]
    
    static let sampleChatRooms: [ChatRoom] = [
        ChatRoom(
            id: "chat1",
            participants: ["user1", "user2"],
            lastMessage: sampleChatMessages.last,
            lastMessageTime: sampleChatMessages.last?.timestamp,
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date().addingTimeInterval(-2400)
        ),
        ChatRoom(
            id: "chat2",
            participants: ["user1", "user3"],
            lastMessage: ChatMessage(
                id: "msg6",
                senderId: "user3",
                content: "Great seeing you at the barber shop today!",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                replyTo: nil
            ),
            lastMessageTime: Date().addingTimeInterval(-7200),
            createdAt: Date().addingTimeInterval(-172800),
            updatedAt: Date().addingTimeInterval(-7200)
        ),
        ChatRoom(
            id: "chat3",
            participants: ["user1", "user4"],
            lastMessage: ChatMessage(
                id: "msg7",
                senderId: "user4",
                content: "Thanks for the venue recommendation! The photos look amazing.",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-14400),
                isRead: true,
                replyTo: nil
            ),
            lastMessageTime: Date().addingTimeInterval(-14400),
            createdAt: Date().addingTimeInterval(-259200),
            updatedAt: Date().addingTimeInterval(-14400)
        )
    ]
    
    static let sampleChatPreviews: [ChatPreview] = [
        ChatPreview(
            id: "chat1",
            otherUser: sampleUserProfiles[1], // Sarah Johnson
            lastMessage: sampleChatMessages.last,
            unreadCount: 3,
            lastMessageTime: sampleChatMessages.last?.timestamp
        ),
        ChatPreview(
            id: "chat2",
            otherUser: sampleUserProfiles[2], // Mehmet Yılmaz
            lastMessage: ChatMessage(
                id: "msg6",
                senderId: "user3",
                content: "Great seeing you at the barber shop today!",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                replyTo: nil
            ),
            unreadCount: 1,
            lastMessageTime: Date().addingTimeInterval(-7200)
        ),
        ChatPreview(
            id: "chat3",
            otherUser: sampleUserProfiles[3], // Emma Wilson
            lastMessage: ChatMessage(
                id: "msg7",
                senderId: "user4",
                content: "Thanks for the venue recommendation! The photos look amazing.",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-14400),
                isRead: true,
                replyTo: nil
            ),
            unreadCount: 0,
            lastMessageTime: Date().addingTimeInterval(-14400)
        )
    ]
}

