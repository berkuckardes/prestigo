import Foundation
import Combine

// MARK: - Istanbul Restaurant API Models
struct IstanbulRestaurant: Identifiable, Codable, Hashable {
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
    
    // Istanbul-specific fields
    let district: String // e.g., "Beşiktaş", "Kadıköy", "Şişli"
    let cuisine: String // e.g., "Turkish", "Mediterranean", "International"
    let reservationRequired: Bool
    let outdoorSeating: Bool
    let parkingAvailable: Bool
    let creditCardAccepted: Bool
    let halal: Bool
    let vegetarianFriendly: Bool
}

struct ReservationSlot: Identifiable, Codable {
    let id: String
    let restaurantId: String
    let date: Date
    let time: String
    let availableSeats: Int
    let maxCapacity: Int
    let price: Double?
    let isAvailable: Bool
}

struct ReservationRequest: Codable {
    let restaurantId: String
    let date: Date
    let time: String
    let partySize: Int
    let customerName: String
    let customerPhone: String
    let customerEmail: String
    let specialRequests: String?
}

struct ReservationResponse: Codable {
    let success: Bool
    let reservationId: String?
    let message: String
    let confirmationCode: String?
}

// MARK: - Istanbul Restaurant API Service
class IstanbulRestaurantService: ObservableObject {
    @Published var restaurants: [IstanbulRestaurant] = []
    @Published var availableSlots: [ReservationSlot] = []
    @Published var loading = false
    @Published var errorMessage: String?
    
    // API Configuration
    private let baseURL = "https://api.yemeksepeti.com" // Example API
    private let apiKey = "YOUR_API_KEY" // You'll need to get this from the API provider
    
    // Real Istanbul restaurant data (fallback when APIs are not available)
    private let istanbulRestaurants: [IstanbulRestaurant] = [
        IstanbulRestaurant(
            id: "istanbul1",
            name: "Mikla Restaurant",
            category: "restaurant",
            city: "Istanbul",
            description: "Award-winning restaurant by Chef Mehmet Gürs, offering modern Turkish cuisine with stunning views of the Golden Horn and Bosphorus.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
            rating: 4.9,
            priceRange: "$$$",
            address: "The Marmara Pera, Tepebaşı, Beyoğlu, Istanbul",
            phone: "+90 212 293 5656",
            website: "https://miklarestaurant.com",
            hours: ["Monday": "Closed", "Tuesday": "7:00 PM - 11:00 PM", "Wednesday": "7:00 PM - 11:00 PM", "Thursday": "7:00 PM - 11:00 PM", "Friday": "7:00 PM - 11:00 PM", "Saturday": "7:00 PM - 11:00 PM"],
            amenities: ["Bosphorus Views", "Wine Pairing", "Private Dining", "Valet Parking"],
            createdAt: Date(),
            updatedAt: Date(),
            district: "Beyoğlu",
            cuisine: "Modern Turkish",
            reservationRequired: true,
            outdoorSeating: true,
            parkingAvailable: true,
            creditCardAccepted: true,
            halal: true,
            vegetarianFriendly: true
        ),
        IstanbulRestaurant(
            id: "istanbul2",
            name: "Çiya Sofrası",
            category: "restaurant",
            city: "Istanbul",
            description: "Famous for authentic Anatolian cuisine, featuring traditional dishes from different regions of Turkey in a warm, family-friendly atmosphere.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800",
            rating: 4.8,
            priceRange: "$$",
            address: "Güneşli Bahçe Sokak No:43, Kadıköy, Istanbul",
            phone: "+90 216 330 3190",
            website: "https://ciya.com.tr",
            hours: ["Monday": "11:00 AM - 10:00 PM", "Tuesday": "11:00 AM - 10:00 PM", "Wednesday": "11:00 AM - 10:00 PM", "Thursday": "11:00 AM - 10:00 PM", "Friday": "11:00 AM - 10:00 PM", "Saturday": "11:00 AM - 10:00 PM"],
            amenities: ["Traditional Cuisine", "Family Style", "Outdoor Seating", "Local Ingredients"],
            createdAt: Date(),
            updatedAt: Date(),
            district: "Kadıköy",
            cuisine: "Traditional Turkish",
            reservationRequired: false,
            outdoorSeating: true,
            parkingAvailable: false,
            creditCardAccepted: true,
            halal: true,
            vegetarianFriendly: true
        ),
        IstanbulRestaurant(
            id: "istanbul3",
            name: "360 Istanbul",
            category: "restaurant",
            city: "Istanbul",
            description: "Unique rooftop restaurant with 360-degree panoramic views of Istanbul, serving international cuisine with Turkish influences.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800",
            rating: 4.7,
            priceRange: "$$$",
            address: "İstiklal Caddesi No:163, Beyoğlu, Istanbul",
            phone: "+90 212 251 1041",
            website: "https://360istanbul.com",
            hours: ["Monday": "6:00 PM - 1:00 AM", "Tuesday": "6:00 PM - 1:00 AM", "Wednesday": "6:00 PM - 1:00 AM", "Thursday": "6:00 PM - 1:00 AM", "Friday": "6:00 PM - 1:00 AM", "Saturday": "6:00 PM - 1:00 AM"],
            amenities: ["360° Views", "Rooftop Dining", "Cocktail Bar", "Live Music"],
            createdAt: Date(),
            updatedAt: Date(),
            district: "Beyoğlu",
            cuisine: "International",
            reservationRequired: true,
            outdoorSeating: true,
            parkingAvailable: false,
            creditCardAccepted: true,
            halal: false,
            vegetarianFriendly: true
        ),
        IstanbulRestaurant(
            id: "istanbul4",
            name: "Balıkçı Lokantası",
            category: "restaurant",
            city: "Istanbul",
            description: "Historic fish restaurant on the Bosphorus, serving fresh seafood and traditional Turkish mezes since 1950.",
            prestigeLevel: "silver",
            imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800",
            rating: 4.6,
            priceRange: "$$",
            address: "Kemankeş Caddesi No:35, Karaköy, Istanbul",
            phone: "+90 212 292 0000",
            website: "https://balikcilokantasi.com",
            hours: ["Monday": "12:00 PM - 11:00 PM", "Tuesday": "12:00 PM - 11:00 PM", "Wednesday": "12:00 PM - 11:00 PM", "Thursday": "12:00 PM - 11:00 PM", "Friday": "12:00 PM - 11:00 PM", "Saturday": "12:00 PM - 11:00 PM"],
            amenities: ["Bosphorus Views", "Fresh Seafood", "Traditional Mezes", "Wine Selection"],
            createdAt: Date(),
            updatedAt: Date(),
            district: "Karaköy",
            cuisine: "Seafood",
            reservationRequired: true,
            outdoorSeating: true,
            parkingAvailable: false,
            creditCardAccepted: true,
            halal: true,
            vegetarianFriendly: false
        ),
        IstanbulRestaurant(
            id: "istanbul5",
            name: "Nusr-Et Steakhouse",
            category: "restaurant",
            city: "Istanbul",
            description: "Premium steakhouse by celebrity chef Nusret Gökçe, offering world-class steaks and luxury dining experience.",
            prestigeLevel: "gold",
            imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800",
            rating: 4.8,
            priceRange: "$$$$",
            address: "Levent Mahallesi, Büyükdere Caddesi No:185, Şişli, Istanbul",
            phone: "+90 212 319 1999",
            website: "https://nusr-et.com",
            hours: ["Monday": "12:00 PM - 11:00 PM", "Tuesday": "12:00 PM - 11:00 PM", "Wednesday": "12:00 PM - 11:00 PM", "Thursday": "12:00 PM - 11:00 PM", "Friday": "12:00 PM - 11:00 PM", "Saturday": "12:00 PM - 11:00 PM"],
            amenities: ["Premium Steaks", "Wine Cellar", "Private Dining", "Valet Parking"],
            createdAt: Date(),
            updatedAt: Date(),
            district: "Şişli",
            cuisine: "Steakhouse",
            reservationRequired: true,
            outdoorSeating: false,
            parkingAvailable: true,
            creditCardAccepted: true,
            halal: true,
            vegetarianFriendly: false
        )
    ]
    
    init() {
        // Start with local data, then try to fetch from APIs
        self.restaurants = istanbulRestaurants
        fetchFromAPIs()
    }
    
    // MARK: - API Integration Methods
    
    func fetchFromAPIs() {
        loading = true
        errorMessage = nil
        
        // Try multiple Istanbul restaurant APIs
        let group = DispatchGroup()
        
        // 1. Yemeksepeti API
        group.enter()
        fetchFromYemeksepeti { [weak self] in
            group.leave()
        }
        
        // 2. Getir API
        group.enter()
        fetchFromGetir { [weak self] in
            group.leave()
        }
        
        // 3. Yelp Istanbul API
        group.enter()
        fetchFromYelp { [weak self] in
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.loading = false
            if self?.restaurants.count == 0 {
                self?.restaurants = self?.istanbulRestaurants ?? []
            }
        }
    }
    
    private func fetchFromYemeksepeti(completion: @escaping () -> Void) {
        // Yemeksepeti API integration
        let urlString = "\(baseURL)/restaurants/istanbul"
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { completion() }
            
            if let error = error {
                print("Yemeksepeti API error: \(error)")
                return
            }
            
            // Process response and update restaurants
            // This would parse the actual API response
        }.resume()
    }
    
    private func fetchFromGetir(completion: @escaping () -> Void) {
        // Getir API integration
        let urlString = "https://api.getir.com/restaurants/istanbul"
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { completion() }
            
            if let error = error {
                print("Getir API error: \(error)")
                return
            }
            
            // Process response and update restaurants
        }.resume()
    }
    
    private func fetchFromYelp(completion: @escaping () -> Void) {
        // Yelp Istanbul API integration
        let urlString = "https://api.yelp.com/v3/businesses/search?location=Istanbul,Turkey&categories=restaurants"
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { completion() }
            
            if let error = error {
                print("Yelp API error: \(error)")
                return
            }
            
            // Process response and update restaurants
        }.resume()
    }
    
    // MARK: - Reservation Methods
    
    func getAvailableSlots(for restaurantId: String, date: Date) async throws -> [ReservationSlot] {
        // This would integrate with real reservation APIs
        // For now, return mock data
        
        let calendar = Calendar.current
        let startHour = 12 // 12 PM
        let endHour = 22 // 10 PM
        
        var slots: [ReservationSlot] = []
        
        for hour in startHour...endHour {
            let slot = ReservationSlot(
                id: "\(restaurantId)_\(hour)",
                restaurantId: restaurantId,
                date: date,
                time: "\(hour):00",
                availableSeats: Int.random(in: 2...8),
                maxCapacity: 10,
                price: nil,
                isAvailable: Bool.random()
            )
            slots.append(slot)
        }
        
        return slots
    }
    
    func makeReservation(_ request: ReservationRequest) async throws -> ReservationResponse {
        // This would integrate with real reservation APIs
        // For now, return mock response
        
        let success = Bool.random()
        let reservationId = success ? UUID().uuidString : nil
        let message = success ? "Reservation confirmed successfully!" : "Sorry, no availability for this time."
        let confirmationCode = success ? String(format: "%06d", Int.random(in: 100000...999999)) : nil
        
        return ReservationResponse(
            success: success,
            reservationId: reservationId,
            message: message,
            confirmationCode: confirmationCode
        )
    }
    
    // MARK: - Search and Filter Methods
    
    func searchRestaurants(query: String) -> [IstanbulRestaurant] {
        guard !query.isEmpty else { return restaurants }
        return restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(query) ||
            restaurant.district.localizedCaseInsensitiveContains(query) ||
            restaurant.cuisine.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterByDistrict(_ district: String?) -> [IstanbulRestaurant] {
        guard let district = district else { return restaurants }
        return restaurants.filter { $0.district == district }
    }
    
    func filterByCuisine(_ cuisine: String?) -> [IstanbulRestaurant] {
        guard let cuisine = cuisine else { return restaurants }
        return restaurants.filter { $0.cuisine == cuisine }
    }
    
    func getDistricts() -> [String] {
        return Array(Set(restaurants.map { $0.district })).sorted()
    }
    
    func getCuisines() -> [String] {
        return Array(Set(restaurants.map { $0.cuisine })).sorted()
    }
}
