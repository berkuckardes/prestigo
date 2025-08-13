//
//  ExploreView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//

import SwiftUI

struct ExploreView: View {
    @State private var query: String = ""
    @State private var venues: [Venue] = DummyData.venues

    var body: some View {
        NavigationStack {
            List(filteredVenues) { venue in
                NavigationLink(value: venue) {
                    VenueRow(venue: venue)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Explore")
            .navigationDestination(for: Venue.self) { venue in
                VenueDetailView(venue: venue)
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search venues")
        }
    }

    private var filteredVenues: [Venue] {
        guard !query.isEmpty else { return venues }
        return venues.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.category.localizedCaseInsensitiveContains(query) ||
            $0.city.localizedCaseInsensitiveContains(query)
        }
    }
}

struct VenueRow: View {
    let venue: Venue
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: venue.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    ProgressView().frame(width: 72, height: 72)
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "photo").resizable().scaledToFit().padding(16)
                @unknown default:
                    Color.secondary
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(venue.name).font(.headline)
                Text("\(venue.category.capitalized) • \(venue.city)")
                    .font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    PrestigeBadge(level: venue.prestigeLevel)
                    Text(venue.address).lineLimit(1).foregroundStyle(.secondary)
                }.font(.caption)
            }
        }
        .padding(.vertical, 6)
    }
}
