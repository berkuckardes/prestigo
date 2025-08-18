//
//  ExploreView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//

import SwiftUI

// MARK: - Sort Options
enum SortOption: String, CaseIterable {
    case `default` = "Default"
    case rating = "Rating"
    case name = "Name"
    case distance = "Distance"
    
    var icon: String {
        switch self {
        case .default: return "star.circle"
        case .rating: return "star.fill"
        case .name: return "textformat.abc"
        case .distance: return "location.circle"
        }
    }
}

struct ExploreView: View {
    @State private var query: String = ""
    @State private var selectedCategory: String?
    @State private var selectedPrestigeLevel: String?
    @State private var showListView = false
    @State private var venues: [Venue] = DummyData.venues
    @State private var sortOption: SortOption = .default
    
    // Grid layout configuration
    private let columns = [
        GridItem(.fixed((UIScreen.main.bounds.width - 80) / 2), spacing: 32),
        GridItem(.fixed((UIScreen.main.bounds.width - 80) / 2), spacing: 32)
    ]
    
    // Get unique categories from venues
    private var categories: [String] {
        Array(Set(venues.map { $0.category })).sorted()
    }
    
    // Get unique prestige levels from venues
    private var prestigeLevels: [String] {
        Array(Set(venues.map { $0.prestigeLevel })).sorted { level1, level2 in
            let prestigeOrder = ["gold": 3, "silver": 2, "bronze": 1]
            let order1 = prestigeOrder[level1.lowercased()] ?? 0
            let order2 = prestigeOrder[level2.lowercased()] ?? 0
            return order1 > order2
        }
    }
    
    // Get featured venues (top 3 by prestige level)
    private var featuredVenues: [Venue] {
        let sortedVenues = venues.sorted { venue1, venue2 in
            let prestigeOrder = ["gold": 3, "silver": 2, "bronze": 1]
            let level1 = prestigeOrder[venue1.prestigeLevel.lowercased()] ?? 0
            let level2 = prestigeOrder[venue2.prestigeLevel.lowercased()] ?? 0
            return level1 > level2
        }
        return Array(sortedVenues.prefix(3))
    }
    
    // Filter venues based on selections
    private var filteredVenues: [Venue] {
        var filtered = venues.filter { venue in
            let categoryMatch = selectedCategory == nil || venue.category == selectedCategory
            let prestigeMatch = selectedPrestigeLevel == nil || venue.prestigeLevel == selectedPrestigeLevel
            let queryMatch = query.isEmpty || venue.name.localizedCaseInsensitiveContains(query)
            return categoryMatch && prestigeMatch && queryMatch
        }
        
        // Apply sorting
        switch sortOption {
        case .default:
            // Keep original order (by prestige level)
            filtered.sort { venue1, venue2 in
                let prestigeOrder = ["gold": 3, "silver": 2, "bronze": 1]
                let level1 = prestigeOrder[venue1.prestigeLevel.lowercased()] ?? 0
                let level2 = prestigeOrder[venue2.prestigeLevel.lowercased()] ?? 0
                return level1 > level2
            }
        case .rating:
            // Sort by rating (highest first)
            filtered.sort { venue1, venue2 in
                let rating1 = getVenueRating(venue1)
                let rating2 = getVenueRating(venue2)
                return rating1 > rating2
            }
        case .name:
            // Sort alphabetically by name
            filtered.sort { $0.name < $1.name }
        case .distance:
            // Sort by distance (closest first) - placeholder for now
            filtered.sort { venue1, venue2 in
                let distance1 = getVenueDistance(venue1)
                let distance2 = getVenueDistance(venue2)
                return distance1 < distance2
            }
        }
        
        return filtered
    }
    
    // Helper function to get venue rating (placeholder - would come from real data)
    private func getVenueRating(_ venue: Venue) -> Double {
        // Simulate different ratings based on venue properties
        let baseRating = 4.0
        let prestigeBonus = venue.prestigeLevel == "gold" ? 0.8 : venue.prestigeLevel == "silver" ? 0.4 : 0.0
        let categoryBonus = venue.category == "restaurant" ? 0.3 : venue.category == "spa" ? 0.2 : 0.1
        return min(5.0, baseRating + prestigeBonus + categoryBonus + Double.random(in: -0.2...0.2))
    }
    
    // Helper function to get venue distance (placeholder - would come from real data)
    private func getVenueDistance(_ venue: Venue) -> Double {
        // Simulate distances based on venue location
        let baseDistance = Double.random(in: 0.5...5.0)
        return baseDistance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Section
                        heroSection
                        
                        // Filters Section
                        filtersSection
                        
                        // Venues Section
                        venuesSection
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationDestination(for: Venue.self) { venue in
                VenueDetailView(venue: venue)
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search venues")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    clearFiltersButton
                }
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("Discover")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Find the perfect venue for your next experience")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Featured venues carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(featuredVenues) { venue in
                        FeaturedVenueCard(venue: venue)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Filters Section
    private var filtersSection: some View {
        VStack(spacing: 24) {
            // Categories
            VStack(alignment: .leading, spacing: 16) {
                Text("Categories")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(categories, id: \.self) { category in
                            FilterPill(
                                title: category.capitalized,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Prestige Levels
            VStack(alignment: .leading, spacing: 16) {
                Text("Prestige Levels")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(
                            title: "All Levels",
                            isSelected: selectedPrestigeLevel == nil,
                            action: { selectedPrestigeLevel = nil }
                        )
                        
                        ForEach(prestigeLevels, id: \.self) { level in
                            PrestigeFilterPill(
                                title: level.capitalized,
                                isSelected: selectedPrestigeLevel == level,
                                action: { selectedPrestigeLevel = level }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Venues Section
    private var venuesSection: some View {
        VStack(spacing: 20) {
            // Section header with view toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Venues")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(filteredVenues.count) venues found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // View toggle button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showListView.toggle()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: showListView ? "square.grid.2x2" : "list.bullet")
                            .font(.system(size: 16, weight: .medium))
                        Text(showListView ? "Grid" : "List")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                // Sort button
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                sortOption = option
                            }
                        } label: {
                            HStack {
                                Image(systemName: option.icon)
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: sortOption.icon)
                            .font(.system(size: 16, weight: .medium))
                        Text(sortOption.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            
            // Venues display
            if showListView {
                listView
            } else {
                gridView
            }
        }
        .padding(.bottom, 100)
    }
    
    // MARK: - List View
    private var listView: some View {
        LazyVStack(spacing: 0) {
            ForEach(filteredVenues) { venue in
                NavigationLink(value: venue) {
                    VenueListRow(venue: venue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                if venue.id != filteredVenues.last?.id {
                    Divider()
                        .padding(.leading, 100)
                        .padding(.trailing, 20)
                        .opacity(0.2)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Grid View
    private var gridView: some View {
        LazyVGrid(columns: columns, spacing: 48) {
            ForEach(filteredVenues) { venue in
                NavigationLink(value: venue) {
                    VenueGridCard(venue: venue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Clear Filters Button
    private var clearFiltersButton: some View {
        Button("Clear") {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedCategory = nil
                selectedPrestigeLevel = nil
                query = ""
                sortOption = .default
            }
        }
        .foregroundColor(.blue)
        .opacity((selectedCategory != nil || selectedPrestigeLevel != nil || !query.isEmpty || sortOption != .default) ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
        .animation(.easeInOut(duration: 0.2), value: selectedPrestigeLevel)
        .animation(.easeInOut(duration: 0.2), value: query)
        .animation(.easeInOut(duration: 0.2), value: sortOption)
    }
}

// MARK: - Filter Pill Component
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    isSelected ? 
                    Color.blue : 
                    Color(.systemGray6)
                )
                .foregroundColor(
                    isSelected ? .white : .primary
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.blue.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Prestige Filter Pill Component
struct PrestigeFilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if title != "All Levels" {
                    Circle()
                        .fill(prestigeColor)
                        .frame(width: 10, height: 10)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                isSelected ? prestigeColor : Color(.systemGray6)
            )
            .foregroundColor(
                isSelected ? .white : .primary
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? prestigeColor.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var prestigeColor: Color {
        if title.lowercased() == "gold" {
            return .yellow
        } else if title.lowercased() == "silver" {
            return .gray
        } else if title.lowercased() == "bronze" {
            return .orange
        } else {
            return .blue
        }
    }
}
