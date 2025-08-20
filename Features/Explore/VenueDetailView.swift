//
//  VenueDetailView.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import SwiftUI
import MapKit

struct VenueDetailView: View {
    let venue: Venue
    @State private var region: MKCoordinateRegion

    init(venue: Venue) {
        self.venue = venue
        // Use a default coordinate since Venue no longer has coordinate property
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // Default to NYC
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        ScrollView {
            // Hero image
            AsyncImage(url: URL(string: venue.imageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.gray.opacity(0.2))
            }
            .frame(height: 220)
            .clipped()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(venue.name)
                        .font(.title2).bold()
                    Spacer()
                    PrestigeBadge(level: venue.prestigeLevel)
                }

                Text("\(venue.category.capitalized) • \(venue.city)")
                    .foregroundStyle(.secondary)

                // Map
                Map(coordinateRegion: $region)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Slots
                NavigationLink {
                    SlotPickerView(venueId: venue.id, venueName: venue.name)
                } label: {
                    Text("See available slots")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {        // keep content above tab bar
            Color.clear.frame(height: 88)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
