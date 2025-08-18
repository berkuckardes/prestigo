//
//  VenueModels.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import Foundation
import CoreLocation

struct Venue: Identifiable {
    let id: String
    let name: String
    let category: String // restaurant, barber, spa...
    let city: String
    let prestigeLevel: String // bronze/silver/gold
    let address: String
    let coordinate: CLLocationCoordinate2D
    let thumbnailURL: URL?
}

// Equatable & Hashable based on id (stable, simple)
extension Venue: Equatable {
    static func == (lhs: Venue, rhs: Venue) -> Bool { lhs.id == rhs.id }
}

extension Venue: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum DummyData {
    static let venues: [Venue] = [
        Venue(
            id: "neo",
            name: "Neolokal",
            category: "restaurant",
            city: "Istanbul",
            prestigeLevel: "gold",
            address: "Salt Galata, Karaköy",
            coordinate: .init(latitude: 41.0249, longitude: 28.9733),
            thumbnailURL: URL(string: "https://picsum.photos/seed/neo/600/400")
        ),
        Venue(
            id: "tonyguy",
            name: "Toni&Guy Nişantaşı",
            category: "barber",
            city: "Istanbul",
            prestigeLevel: "silver",
            address: "Nişantaşı",
            coordinate: .init(latitude: 41.0473, longitude: 28.9939),
            thumbnailURL: URL(string: "https://picsum.photos/seed/toni/600/400")
        ),
        Venue(
            id: "mikla",
            name: "Mikla",
            category: "restaurant",
            city: "Istanbul",
            prestigeLevel: "gold",
            address: "The Marmara Pera, Beyoğlu",
            coordinate: .init(latitude: 41.0334, longitude: 28.9758),
            thumbnailURL: URL(string: "https://picsum.photos/seed/mikla/600/400")
        ),
        Venue(
            id: "spa1",
            name: "Luxury Spa & Wellness",
            category: "spa",
            city: "Istanbul",
            prestigeLevel: "gold",
            address: "Beşiktaş",
            coordinate: .init(latitude: 41.0422, longitude: 29.0083),
            thumbnailURL: URL(string: "https://picsum.photos/seed/spa1/600/400")
        ),
        Venue(
            id: "rest1",
            name: "Bosphorus Terrace",
            category: "restaurant",
            city: "Istanbul",
            prestigeLevel: "silver",
            address: "Ortaköy",
            coordinate: .init(latitude: 41.0473, longitude: 29.0273),
            thumbnailURL: URL(string: "https://picsum.photos/seed/rest1/600/400")
        ),
        Venue(
            id: "barber1",
            name: "Elite Barbershop",
            category: "barber",
            city: "Istanbul",
            prestigeLevel: "bronze",
            address: "Kadıköy",
            coordinate: .init(latitude: 40.9909, longitude: 29.0304),
            thumbnailURL: URL(string: "https://picsum.photos/seed/barber1/600/400")
        ),
        Venue(
            id: "spa2",
            name: "Zen Garden Spa",
            category: "spa",
            city: "Istanbul",
            prestigeLevel: "silver",
            address: "Şişli",
            coordinate: .init(latitude: 41.0602, longitude: 28.9877),
            thumbnailURL: URL(string: "https://picsum.photos/seed/spa2/600/400")
        ),
        Venue(
            id: "rest2",
            name: "Anatolian Kitchen",
            category: "restaurant",
            city: "Istanbul",
            prestigeLevel: "bronze",
            address: "Fatih",
            coordinate: .init(latitude: 41.0082, longitude: 28.9784),
            thumbnailURL: URL(string: "https://picsum.photos/seed/rest2/600/400")
        ),
        Venue(
            id: "barber2",
            name: "Classic Cuts",
            category: "barber",
            city: "Istanbul",
            prestigeLevel: "silver",
            address: "Bakırköy",
            coordinate: .init(latitude: 40.9819, longitude: 28.8772),
            thumbnailURL: URL(string: "https://picsum.photos/seed/barber2/600/400")
        )
    ]
}
