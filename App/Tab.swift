//
//  Tab.swift
//  prestigo
//
//  Created by Berk  on 12.08.2025.
//
import Foundation

enum Tab: CaseIterable {
    case explore, bookings, friends, profile

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .bookings: return "Bookings"
        case .friends:  return "Friends"
        case .profile:  return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .explore: return "magnifyingglass"
        case .bookings: return "calendar"
        case .friends:  return "person.2"
        case .profile:  return "person.crop.circle"
        }
    }
}
