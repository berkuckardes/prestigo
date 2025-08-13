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
        )
    ]
}
