import SwiftUI

// MARK: - Featured Venue Card Component
struct FeaturedVenueCard: View {
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with gradient overlay
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: venue.thumbnailURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.secondary)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            )
                    @unknown default:
                        Color(.systemGray6)
                    }
                }
                .frame(width: 240, height: 140)
                .clipped()
                
                // Gradient overlay for better text readability
                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 240, height: 140)
                
                // Content overlay
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(venue.category.capitalized)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        PrestigeBadge(level: venue.prestigeLevel)
                            .scaleEffect(0.8)
                    }
                    
                    Spacer()
                    
                    Text(venue.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption2)
                        Text(venue.city)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                    }
                }
                .padding(16)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Venue List Row Component
struct VenueListRow: View {
    let venue: Venue
    
    var body: some View {
        HStack(spacing: 16) {
            // Venue image
            AsyncImage(url: venue.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.secondary)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        )
                @unknown default:
                    Color(.systemGray6)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Venue information
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(venue.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    PrestigeBadge(level: venue.prestigeLevel)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: categoryIcon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(venue.category.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "location.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(venue.city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Rating and price (placeholder)
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("4.8")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < 2 ? "dollarsign.circle.fill" : "dollarsign.circle")
                                .foregroundColor(index < 2 ? .green : .secondary)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var categoryIcon: String {
        switch venue.category.lowercased() {
        case "restaurant": return "fork.knife"
        case "barber": return "scissors"
        case "spa": return "sparkles"
        case "gym": return "dumbbell.fill"
        case "salon": return "paintbrush.fill"
        default: return "building.2"
        }
    }
}

// MARK: - Venue Grid Card Component
struct VenueGridCard: View {
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with category badge
            ZStack(alignment: .topLeading) {
                AsyncImage(url: venue.thumbnailURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.secondary)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            )
                    @unknown default:
                        Color(.systemGray6)
                    }
                }
                .frame(height: 100)
                .clipped()
                
                // Category badge
                Text(venue.category.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Name and prestige
                HStack(alignment: .firstTextBaseline) {
                    Text(venue.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer(minLength: 2)
                    
                    PrestigeBadge(level: venue.prestigeLevel)
                        .scaleEffect(0.8)
                }

                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(venue.city)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Rating and price
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        Text("4.8")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 1) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < 2 ? "dollarsign.circle.fill" : "dollarsign.circle")
                                .foregroundColor(index < 2 ? .green : .secondary)
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// PrestigeBadge is already defined in Components/PrestigeBadge.swift
