//
//  VenueModels.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import Foundation
import FirebaseFirestore

// MARK: - Venue Model
struct Venue: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: String
    let city: String
    let description: String
    let prestigeLevel: String
    let imageURL: String?
    let rating: Double
    let priceRange: String
    let address: String
    let phone: String?
    let website: String?
    let hours: [String: String]
    let amenities: [String]
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Venue Service
class VenueService: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var loading = false
    @Published var errorMessage: String?
    @Published var isUsingRealData = false
    
    private let db = Firestore.firestore()
    private var venuesListener: ListenerRegistration?
    
    init() {
        fetchVenues()
    }
    
    deinit {
        venuesListener?.remove()
    }
    
    func fetchVenues() {
        loading = true
        errorMessage = nil
        
        // Remove existing listener
        venuesListener?.remove()
        
        // Set up real-time listener for venues
        venuesListener = db.collection("venues")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Firestore error: \(error.localizedDescription)")
                        // Fallback to dummy data if Firestore fails
                        self.useDummyData()
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("No venues found in Firestore, using dummy data")
                        // Fallback to dummy data if no documents found
                        self.useDummyData()
                        return
                    }
                    
                    // Parse venues from Firestore documents
                    self.venues = documents.compactMap { document -> Venue? in
                        do {
                            let data = document.data()
                            
                            // Create venue from Firestore data
                            let venue = Venue(
                                id: document.documentID,
                                name: data["name"] as? String ?? "",
                                category: data["category"] as? String ?? "",
                                city: data["city"] as? String ?? "",
                                description: data["description"] as? String ?? "",
                                prestigeLevel: data["prestigeLevel"] as? String ?? "bronze",
                                imageURL: data["imageURL"] as? String,
                                rating: data["rating"] as? Double ?? 0.0,
                                priceRange: data["priceRange"] as? String ?? "$",
                                address: data["address"] as? String ?? "",
                                phone: data["phone"] as? String,
                                website: data["website"] as? String,
                                hours: data["hours"] as? [String: String] ?? [:],
                                amenities: data["amenities"] as? [String] ?? [],
                                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                            )
                            return venue
                        } catch {
                            print("Error parsing venue document: \(error)")
                            return nil
                        }
                    }
                    
                    // If no venues were parsed successfully, fallback to dummy data
                    if self.venues.isEmpty {
                        print("No venues parsed successfully, using dummy data")
                        self.useDummyData()
                        return
                    }
                    
                    self.loading = false
                    self.errorMessage = nil
                    self.isUsingRealData = true
                    print("Successfully loaded \(self.venues.count) venues from Firestore")
                }
            }
    }
    
    // Fallback to dummy data if Firestore fails
    func useDummyData() {
        loading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.venues = DummyData.venues
            self.loading = false
            self.errorMessage = nil
            self.isUsingRealData = false
        }
    }
    
    // Add a new venue to Firestore
    func addVenue(_ venue: Venue) {
        do {
            let data: [String: Any] = [
                "name": venue.name,
                "category": venue.category,
                "city": venue.city,
                "description": venue.description,
                "prestigeLevel": venue.prestigeLevel,
                "imageURL": venue.imageURL ?? "",
                "rating": venue.rating,
                "priceRange": venue.priceRange,
                "address": venue.address,
                "phone": venue.phone ?? "",
                "website": venue.website ?? "",
                "hours": venue.hours,
                "amenities": venue.amenities,
                "createdAt": Timestamp(date: venue.createdAt),
                "updatedAt": Timestamp(date: venue.updatedAt)
            ]
            
            db.collection("venues").addDocument(data: data) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = "Failed to add venue: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            errorMessage = "Failed to prepare venue data: \(error.localizedDescription)"
        }
    }
    
    // Seed Firestore with initial venue data
    func seedInitialVenues() {
        print("Seeding Firestore with initial venue data...")
        
        for venue in DummyData.venues {
            addVenue(venue)
        }
        
        print("Initial venue seeding completed")
    }
    
    func searchVenues(query: String) -> [Venue] {
        guard !query.isEmpty else { return venues }
        return venues.filter { venue in
            venue.name.localizedCaseInsensitiveContains(query) ||
            venue.category.localizedCaseInsensitiveContains(query) ||
            venue.city.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterVenues(category: String?, prestigeLevel: String?) -> [Venue] {
        return venues.filter { venue in
            let categoryMatch = category == nil || venue.category == category
            let prestigeMatch = prestigeLevel == nil || venue.prestigeLevel == prestigeLevel
            return categoryMatch && prestigeMatch
        }
    }
    
    func sortVenues(_ venues: [Venue], by sortOption: SortOption) -> [Venue] {
        switch sortOption {
        case .default:
            return venues.sorted { venue1, venue2 in
                let prestigeOrder = ["gold": 3, "silver": 2, "bronze": 1]
                let level1 = prestigeOrder[venue1.prestigeLevel.lowercased()] ?? 0
                let level2 = prestigeOrder[venue2.prestigeLevel.lowercased()] ?? 0
                return level1 > level2
            }
        case .rating:
            return venues.sorted { $0.rating > $1.rating }
        case .name:
            return venues.sorted { $0.name < $1.name }
        case .distance:
            // For now, return as-is since we don't have real location data
            return venues
        }
    }
    
    func getFeaturedVenues() -> [Venue] {
        return Array(venues.prefix(3))
    }
    
    func getCategories() -> [String] {
        return Array(Set(venues.map { $0.category })).sorted()
    }
    
    func getPrestigeLevels() -> [String] {
        return Array(Set(venues.map { $0.prestigeLevel })).sorted { level1, level2 in
            let prestigeOrder = ["gold": 3, "silver": 2, "bronze": 1]
            let order1 = prestigeOrder[level1.lowercased()] ?? 0
            let order2 = prestigeOrder[level2.lowercased()] ?? 0
            return order1 > order2
        }
    }
}

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

// MARK: - Dummy Data (for fallback)
struct DummyData {
    static let venues: [Venue] = [
        // REAL RESTAURANTS
        Venue(
            id: "venue1",
            name: "Le Bernardin",
            category: "restaurant",
            city: "New York",
            description: "Four-star Michelin restaurant by Chef Eric Ripert, specializing in seafood with French techniques. Known for its elegant dining room and exceptional service.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
            rating: 4.9,
            priceRange: "$$$$",
            address: "155 W 51st St, New York, NY 10019",
            phone: "+1 (212) 554-1515",
            website: "https://le-bernardin.com",
            hours: ["Monday": "5:30 PM - 10:30 PM", "Tuesday": "5:30 PM - 10:30 PM", "Wednesday": "5:30 PM - 10:30 PM", "Thursday": "5:30 PM - 10:30 PM", "Friday": "5:30 PM - 10:30 PM", "Saturday": "5:30 PM - 10:30 PM"],
            amenities: ["Valet Parking", "Private Dining", "Wine Pairing", "Chef's Table"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue2",
            name: "Nobu Los Angeles",
            category: "restaurant",
            city: "Los Angeles",
            description: "Celebrity chef Nobu Matsuhisa's flagship restaurant featuring innovative Japanese-Peruvian fusion cuisine in a sophisticated setting.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800",
            rating: 4.8,
            priceRange: "$$$",
            address: "903 N La Cienega Blvd, Los Angeles, CA 90069",
            phone: "+1 (310) 657-0404",
            website: "https://noburestaurants.com",
            hours: ["Monday": "6:00 PM - 11:00 PM", "Tuesday": "6:00 PM - 11:00 PM", "Wednesday": "6:00 PM - 11:00 PM", "Thursday": "6:00 PM - 11:00 PM", "Friday": "6:00 PM - 11:00 PM", "Saturday": "6:00 PM - 11:00 PM"],
            amenities: ["Sushi Bar", "Private Rooms", "Cocktail Lounge", "Valet Parking"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue3",
            name: "Joe's Stone Crab",
            category: "restaurant",
            city: "Miami",
            description: "Historic Miami Beach institution since 1913, famous for its stone crab claws and classic seafood dishes in an elegant Art Deco setting.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800",
            rating: 4.7,
            priceRange: "$$$",
            address: "11 Washington Ave, Miami Beach, FL 33139",
            phone: "+1 (305) 673-0365",
            website: "https://joesstonecrab.com",
            hours: ["Monday": "5:00 PM - 10:00 PM", "Tuesday": "5:00 PM - 10:00 PM", "Wednesday": "5:00 PM - 10:00 PM", "Thursday": "5:00 PM - 10:00 PM", "Friday": "5:00 PM - 10:00 PM", "Saturday": "5:00 PM - 10:00 PM"],
            amenities: ["Waterfront Dining", "Private Dining", "Full Bar", "Valet Parking"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        // REAL HOTELS
        Venue(
            id: "venue4",
            name: "The Ritz-Carlton, New York",
            category: "hotel",
            city: "New York",
            description: "Luxury hotel in the heart of Manhattan offering world-class accommodations, fine dining, and exceptional service with Central Park views.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800",
            rating: 4.9,
            priceRange: "$$$$",
            address: "50 Central Park S, New York, NY 10019",
            phone: "+1 (212) 308-9100",
            website: "https://ritzcarlton.com",
            hours: ["Monday": "24/7", "Tuesday": "24/7", "Wednesday": "24/7", "Thursday": "24/7", "Friday": "24/7", "Saturday": "24/7", "Sunday": "24/7"],
            amenities: ["Central Park Views", "Spa & Wellness", "Fine Dining", "Concierge Service", "Fitness Center"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue5",
            name: "The Beverly Hills Hotel",
            category: "hotel",
            city: "Los Angeles",
            description: "Iconic pink palace hotel in Beverly Hills, known for its legendary service, celebrity clientele, and luxurious accommodations since 1912.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800",
            rating: 4.8,
            priceRange: "$$$$",
            address: "9641 Sunset Blvd, Beverly Hills, CA 90210",
            phone: "+1 (310) 276-2251",
            website: "https://dorchestercollection.com",
            hours: ["Monday": "24/7", "Tuesday": "24/7", "Wednesday": "24/7", "Thursday": "24/7", "Friday": "24/7", "Saturday": "24/7", "Sunday": "24/7"],
            amenities: ["Polo Lounge", "Spa & Wellness", "Swimming Pool", "Tennis Courts", "Private Bungalows"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        // REAL SPAS
        Venue(
            id: "venue6",
            name: "The Spa at Mandarin Oriental",
            category: "spa",
            city: "New York",
            description: "Luxury spa offering holistic wellness treatments, traditional Asian healing therapies, and stunning city views in a serene environment.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800",
            rating: 4.9,
            priceRange: "$$$",
            address: "80 Columbus Circle, New York, NY 10023",
            phone: "+1 (212) 805-8880",
            website: "https://mandarinoriental.com",
            hours: ["Monday": "9:00 AM - 8:00 PM", "Tuesday": "9:00 AM - 8:00 PM", "Wednesday": "9:00 AM - 8:00 PM", "Thursday": "9:00 AM - 8:00 PM", "Friday": "9:00 AM - 8:00 PM", "Saturday": "9:00 AM - 8:00 PM"],
            amenities: ["Asian Healing Therapies", "Private Treatment Rooms", "Steam Room", "Relaxation Lounge", "Wellness Consultations"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue7",
            name: "Beverly Hot Springs Spa",
            category: "spa",
            city: "Los Angeles",
            description: "Natural hot springs spa in the heart of LA, featuring authentic Korean-style treatments and therapeutic mineral waters.",
            prestigeLevel: "silver",
            imageURL: "https://images.unsplash.com/photo-1544161512-6f8a0286f9a1?w=800",
            rating: 4.6,
            priceRange: "$$",
            address: "308 N Oxford Ave, Los Angeles, CA 90004",
            phone: "+1 (323) 734-7000",
            website: "https://beverlyhotsprings.com",
            hours: ["Monday": "10:00 AM - 9:00 PM", "Tuesday": "10:00 AM - 9:00 PM", "Wednesday": "10:00 AM - 9:00 PM", "Thursday": "10:00 AM - 9:00 PM", "Friday": "10:00 AM - 9:00 PM", "Saturday": "10:00 AM - 9:00 PM"],
            amenities: ["Natural Hot Springs", "Korean Bath House", "Massage Therapy", "Sauna", "Private Rooms"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        // REAL GOLF COURSES
        Venue(
            id: "venue8",
            name: "Pebble Beach Golf Links",
            category: "golf",
            city: "Pebble Beach",
            description: "World-famous golf course on the stunning California coastline, host to multiple U.S. Open Championships and considered one of the most beautiful courses in the world.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800",
            rating: 4.9,
            priceRange: "$$$$",
            address: "1700 17-Mile Drive, Pebble Beach, CA 93953",
            phone: "+1 (831) 622-8723",
            website: "https://pebblebeach.com",
            hours: ["Monday": "6:30 AM - 6:00 PM", "Tuesday": "6:30 AM - 6:00 PM", "Wednesday": "6:30 AM - 6:00 PM", "Thursday": "6:30 AM - 6:00 PM", "Friday": "6:30 AM - 6:00 PM", "Saturday": "6:30 AM - 6:00 PM"],
            amenities: ["Ocean Views", "Pro Shop", "Driving Range", "Clubhouse", "Fine Dining", "Lodging"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue9",
            name: "TPC Sawgrass",
            category: "golf",
            city: "Ponte Vedra Beach",
            description: "Home of THE PLAYERS Championship, featuring the iconic island green 17th hole and championship-level facilities in beautiful Florida.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800",
            rating: 4.8,
            priceRange: "$$$",
            address: "110 Championship Way, Ponte Vedra Beach, FL 32082",
            phone: "+1 (904) 273-3235",
            website: "https://tpc.com",
            hours: ["Monday": "7:00 AM - 6:00 PM", "Tuesday": "7:00 AM - 6:00 PM", "Wednesday": "7:00 AM - 6:00 PM", "Thursday": "7:00 AM - 6:00 PM", "Friday": "7:00 AM - 6:00 PM", "Saturday": "7:00 AM - 6:00 PM"],
            amenities: ["Championship Course", "Pro Shop", "Practice Facilities", "Clubhouse", "Fine Dining"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        // REAL BAKERIES & CAFES
        Venue(
            id: "venue10",
            name: "Tartine Bakery",
            category: "bakery",
            city: "San Francisco",
            description: "Acclaimed artisan bakery known for its sourdough bread, pastries, and commitment to quality ingredients and traditional baking methods.",
            prestigeLevel: "silver",
            imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800",
            rating: 4.7,
            priceRange: "$$",
            address: "600 Guerrero St, San Francisco, CA 94110",
            phone: "+1 (415) 487-2600",
            website: "https://tartinebakery.com",
            hours: ["Monday": "8:00 AM - 7:00 PM", "Tuesday": "8:00 AM - 7:00 PM", "Wednesday": "8:00 AM - 7:00 PM", "Thursday": "8:00 AM - 7:00 PM", "Friday": "8:00 AM - 7:00 PM", "Saturday": "8:00 AM - 7:00 PM"],
            amenities: ["Artisan Bread", "Pastries", "Coffee Bar", "Outdoor Seating", "Baking Classes"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue11",
            name: "Dominique Ansel Bakery",
            category: "bakery",
            city: "New York",
            description: "Innovative bakery by Chef Dominique Ansel, creator of the Cronut, offering creative pastries and French-inspired desserts.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800",
            rating: 4.8,
            priceRange: "$$",
            address: "189 Spring St, New York, NY 10012",
            phone: "+1 (212) 219-2773",
            website: "https://dominiqueansel.com",
            hours: ["Monday": "8:00 AM - 7:00 PM", "Tuesday": "8:00 AM - 7:00 PM", "Wednesday": "8:00 AM - 7:00 PM", "Thursday": "8:00 AM - 7:00 PM", "Friday": "8:00 AM - 7:00 PM", "Saturday": "8:00 AM - 7:00 PM"],
            amenities: ["Cronut", "French Pastries", "Coffee", "Outdoor Seating", "Baking Classes"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        // REAL ENTERTAINMENT VENUES
        Venue(
            id: "venue12",
            name: "The Blue Note Jazz Club",
            category: "entertainment",
            city: "New York",
            description: "Legendary jazz club in Greenwich Village, hosting world-class jazz musicians in an intimate, historic setting since 1981.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800",
            rating: 4.8,
            priceRange: "$$",
            address: "131 W 3rd St, New York, NY 10012",
            phone: "+1 (212) 475-8592",
            website: "https://bluenotejazz.com",
            hours: ["Monday": "6:00 PM - 12:00 AM", "Tuesday": "6:00 PM - 12:00 AM", "Wednesday": "6:00 PM - 12:00 AM", "Thursday": "6:00 PM - 12:00 AM", "Friday": "6:00 PM - 12:00 AM", "Saturday": "6:00 PM - 12:00 AM"],
            amenities: ["Live Jazz", "Full Bar", "Dinner Service", "Intimate Seating", "Artist Meet & Greets"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue13",
            name: "The Comedy Store",
            category: "entertainment",
            city: "Los Angeles",
            description: "Historic comedy club on the Sunset Strip, launching pad for countless comedians and a must-visit for comedy fans in LA.",
            prestigeLevel: "silver",
            imageURL: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800",
            rating: 4.6,
            priceRange: "$$",
            address: "8433 Sunset Blvd, West Hollywood, CA 90069",
            phone: "+1 (323) 650-6268",
            website: "https://thecomedystore.com",
            hours: ["Monday": "7:00 PM - 2:00 AM", "Tuesday": "7:00 PM - 2:00 AM", "Wednesday": "7:00 PM - 2:00 AM", "Thursday": "7:00 PM - 2:00 AM", "Friday": "7:00 PM - 2:00 AM", "Saturday": "7:00 PM - 2:00 AM"],
            amenities: ["Stand-up Comedy", "Full Bar", "Multiple Stages", "Celebrity Performers", "Late Night Shows"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        // REAL FITNESS & WELLNESS
        Venue(
            id: "venue14",
            name: "Equinox Sports Club",
            category: "fitness",
            city: "New York",
            description: "Premium fitness club offering state-of-the-art equipment, personal training, group classes, and luxury amenities in Manhattan.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800",
            rating: 4.7,
            priceRange: "$$$",
            address: "160 Columbus Ave, New York, NY 10023",
            phone: "+1 (212) 362-9200",
            website: "https://equinox.com",
            hours: ["Monday": "5:00 AM - 11:00 PM", "Tuesday": "5:00 AM - 11:00 PM", "Wednesday": "5:00 AM - 11:00 PM", "Thursday": "5:00 AM - 11:00 PM", "Friday": "5:00 AM - 11:00 PM", "Saturday": "7:00 AM - 9:00 PM"],
            amenities: ["Premium Equipment", "Personal Training", "Group Classes", "Spa Services", "Locker Rooms", "Cafe"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Venue(
            id: "venue15",
            name: "Barry's Bootcamp",
            category: "fitness",
            city: "Los Angeles",
            description: "High-intensity interval training studio combining cardio and strength training in a motivating, energetic environment.",
            prestigeLevel: "silver",
            imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800",
            rating: 4.6,
            priceRange: "$$",
            address: "8500 Beverly Blvd, Los Angeles, CA 90048",
            phone: "+1 (310) 360-0000",
            website: "https://barrys.com",
            hours: ["Monday": "5:30 AM - 8:00 PM", "Tuesday": "5:30 AM - 8:00 PM", "Wednesday": "5:30 AM - 8:00 PM", "Thursday": "5:30 AM - 8:00 PM", "Friday": "5:30 AM - 8:00 PM", "Saturday": "7:00 AM - 6:00 PM"],
            amenities: ["HIIT Training", "Personal Training", "Group Classes", "Shower Facilities", "Fitness Shop"],
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
