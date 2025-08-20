import SwiftUI

struct IstanbulExploreView: View {
    @StateObject private var istanbulService = IstanbulRestaurantService()
    @State private var query: String = ""
    @State private var selectedDistrict: String?
    @State private var selectedCuisine: String?
    @State private var showListView = false
    @State private var sortOption: IstanbulSortOption = .default
    
    // Grid layout configuration
    private let columns = [
        GridItem(.fixed((UIScreen.main.bounds.width - 80) / 2), spacing: 32),
        GridItem(.fixed((UIScreen.main.bounds.width - 80) / 2), spacing: 32)
    ]
    
    // Get unique districts from restaurants
    private var districts: [String] {
        istanbulService.getDistricts()
    }
    
    // Get unique cuisines from restaurants
    private var cuisines: [String] {
        istanbulService.getCuisines()
    }
    
    // Filter restaurants based on selections
    private var filteredRestaurants: [IstanbulRestaurant] {
        let filtered = istanbulService.filterByDistrict(selectedDistrict)
        let cuisineFiltered = istanbulService.filterByCuisine(selectedCuisine)
        let searchFiltered = istanbulService.searchRestaurants(query: query)
        
        let intersection = filtered.filter { restaurant in
            cuisineFiltered.contains { $0.id == restaurant.id } &&
            searchFiltered.contains { $0.id == restaurant.id }
        }
        
        return sortRestaurants(intersection, by: sortOption)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if istanbulService.loading {
                    loadingView
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Hero Section
                            heroSection
                            
                            // Filters Section
                            filtersSection
                            
                            // Restaurants Section
                            restaurantsSection
                        }
                    }
                }
            }
            .navigationTitle("Istanbul")
            .navigationDestination(for: IstanbulRestaurant.self) { restaurant in
                IstanbulReservationView(restaurant: restaurant)
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search Istanbul restaurants")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    clearFiltersButton
                }
            }
            .refreshable {
                istanbulService.fetchFromAPIs()
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading Istanbul restaurants...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("Discover Istanbul")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Experience the finest restaurants in the city where East meets West")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Featured restaurants carousel
            if !istanbulService.restaurants.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(istanbulService.restaurants.prefix(3))) { restaurant in
                            IstanbulFeaturedCard(restaurant: restaurant)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Filters Section
    private var filtersSection: some View {
        VStack(spacing: 24) {
            // Districts
            if !districts.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Districts")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterPill(
                                title: "All Districts",
                                isSelected: selectedDistrict == nil,
                                action: { selectedDistrict = nil }
                            )
                            
                            ForEach(districts, id: \.self) { district in
                                FilterPill(
                                    title: district,
                                    isSelected: selectedDistrict == district,
                                    action: { selectedDistrict = district }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            
            // Cuisines
            if !cuisines.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cuisines")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterPill(
                                title: "All Cuisines",
                                isSelected: selectedCuisine == nil,
                                action: { selectedCuisine = nil }
                            )
                            
                            ForEach(cuisines, id: \.self) { cuisine in
                                FilterPill(
                                    title: cuisine,
                                    isSelected: selectedCuisine == cuisine,
                                    action: { selectedCuisine = cuisine }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Restaurants Section
    private var restaurantsSection: some View {
        VStack(spacing: 20) {
            // Section header with view toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Restaurants")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text("\(filteredRestaurants.count) restaurants found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Data source indicator
                        Text(istanbulService.restaurants.isEmpty ? "Local Data" : "API Data")
                            .font(.caption)
                            .foregroundColor(istanbulService.restaurants.isEmpty ? .orange : .green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(istanbulService.restaurants.isEmpty ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
                            )
                    }
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
                    ForEach(IstanbulSortOption.allCases, id: \.self) { option in
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
            
            // Restaurants display
            if filteredRestaurants.isEmpty {
                emptyStateView
            } else if showListView {
                listView
            } else {
                gridView
            }
        }
        .padding(.bottom, 100)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No restaurants found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your filters or search terms")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - List View
    private var listView: some View {
        LazyVStack(spacing: 0) {
            ForEach(filteredRestaurants) { restaurant in
                NavigationLink(value: restaurant) {
                    IstanbulRestaurantListRow(restaurant: restaurant)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                if restaurant.id != filteredRestaurants.last?.id {
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
            ForEach(filteredRestaurants) { restaurant in
                NavigationLink(value: restaurant) {
                    IstanbulRestaurantGridCard(restaurant: restaurant)
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
                selectedDistrict = nil
                selectedCuisine = nil
                query = ""
            }
        }
        .foregroundColor(.blue)
        .fontWeight(.medium)
    }
    
    // MARK: - Helper Methods
    private func sortRestaurants(_ restaurants: [IstanbulRestaurant], by sortOption: IstanbulSortOption) -> [IstanbulRestaurant] {
        switch sortOption {
        case .default:
            return restaurants.sorted { restaurant1, restaurant2 in
                let prestigeOrder = ["gold": 3, "silver": 2, "bronze": 1]
                let level1 = prestigeOrder[restaurant1.prestigeLevel.lowercased()] ?? 0
                let level2 = prestigeOrder[restaurant2.prestigeLevel.lowercased()] ?? 0
                return level1 > level2
            }
        case .rating:
            return restaurants.sorted { $0.rating > $1.rating }
        case .name:
            return restaurants.sorted { $0.name < $1.name }
        case .district:
            return restaurants.sorted { $0.district < $1.district }
        }
    }
}

// MARK: - Istanbul Sort Options
enum IstanbulSortOption: String, CaseIterable {
    case `default` = "Default"
    case rating = "Rating"
    case name = "Name"
    case district = "District"
    
    var icon: String {
        switch self {
        case .default: return "star.circle"
        case .rating: return "star.fill"
        case .name: return "textformat.abc"
        case .district: return "location.circle"
        }
    }
}

// MARK: - Istanbul Restaurant List Row
struct IstanbulRestaurantListRow: View {
    let restaurant: IstanbulRestaurant
    
    var body: some View {
        HStack(spacing: 16) {
            // Restaurant Image
            if let imageURL = restaurant.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(restaurant.prestigeLevel.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(prestigeColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                    Text(restaurant.district)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(restaurant.cuisine)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                HStack {
                    Label("\(restaurant.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(restaurant.priceRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var prestigeColor: Color {
        switch restaurant.prestigeLevel.lowercased() {
        case "gold": return .yellow
        case "silver": return .gray
        case "bronze": return .orange
        default: return .blue
        }
    }
}

// MARK: - Istanbul Restaurant Grid Card
struct IstanbulRestaurantGridCard: View {
    let restaurant: IstanbulRestaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Restaurant Image
            if let imageURL = restaurant.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(restaurant.prestigeLevel.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(prestigeColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(restaurant.district)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Label("\(restaurant.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(restaurant.priceRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(restaurant.cuisine)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var prestigeColor: Color {
        switch restaurant.prestigeLevel.lowercased() {
        case "gold": return .yellow
        case "silver": return .gray
        case "bronze": return .orange
        default: return .blue
        }
    }
}

// MARK: - Istanbul Featured Card
struct IstanbulFeaturedCard: View {
    let restaurant: IstanbulRestaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Restaurant Image
            if let imageURL = restaurant.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 280, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(restaurant.prestigeLevel.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(prestigeColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                    Text(restaurant.district)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(restaurant.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                }
                
                Text(restaurant.cuisine)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .frame(width: 280)
    }
    
    private var prestigeColor: Color {
        switch restaurant.prestigeLevel.lowercased() {
        case "gold": return .yellow
        case "silver": return .gray
        case "bronze": return .orange
        default: return .blue
        }
    }
}
