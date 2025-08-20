import SwiftUI

// MARK: - Featured Venue Card
struct FeaturedVenueCard: View {
    let venue: Venue
    
    var body: some View {
        ZStack {
            // Background image or placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .frame(width: 280, height: 180)
                .overlay(
                    Group {
                        if let imageURL = venue.imageURL, !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Gradient overlay
            LinearGradient(
                colors: [Color.black.opacity(0.7), Color.clear, Color.black.opacity(0.3)],
                startPoint: .bottom,
                endPoint: .top
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                // Category badge
                HStack {
                    Text(venue.category.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", venue.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                
                // Venue name
                Text(venue.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Location and price
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "location.circle.fill")
                            .font(.caption)
                        Text(venue.city)
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text(venue.priceRange)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
        }
        .frame(width: 280, height: 180)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Venue List Row
struct VenueListRow: View {
    let venue: Venue
    
    var body: some View {
        HStack(spacing: 16) {
            // Venue image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(width: 80, height: 80)
                .overlay(
                    Group {
                        if let imageURL = venue.imageURL, !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Venue details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(venue.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    PrestigeBadge(level: venue.prestigeLevel)
                        .scaleEffect(0.8)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(venue.city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", venue.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Price range
                    Text(venue.priceRange)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Venue Grid Card
struct VenueGridCard: View {
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with category badge
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 140)
                    .overlay(
                        Group {
                            if let imageURL = venue.imageURL, !imageURL.isEmpty {
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary)
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Category badge
                Text(venue.category.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(12)
            }
            
            // Venue details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(venue.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    PrestigeBadge(level: venue.prestigeLevel)
                        .scaleEffect(0.7)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(venue.city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", venue.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Price range
                    Text(venue.priceRange)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Filter Pills
// FilterPill and PrestigeFilterPill are defined in ExploreView.swift
