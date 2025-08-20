# Istanbul Restaurant API Integration Guide

## Overview
This guide explains how to integrate real restaurant APIs for Istanbul to get live reservation data, availability, and restaurant information.

## Available APIs

### 1. Yemeksepeti API
- **Base URL**: `https://api.yemeksepeti.com`
- **Documentation**: [Yemeksepeti Developer Portal](https://developers.yemeksepeti.com)
- **Features**: Restaurant listings, menus, delivery, reviews
- **Authentication**: OAuth 2.0 with Bearer token

### 2. Getir API
- **Base URL**: `https://api.getir.com`
- **Documentation**: [Getir Developer Portal](https://developers.getir.com)
- **Features**: Restaurant discovery, real-time availability
- **Authentication**: API key in headers

### 3. Yelp Fusion API
- **Base URL**: `https://api.yelp.com/v3`
- **Documentation**: [Yelp Fusion API](https://www.yelp.com/developers/documentation/v3)
- **Features**: Business search, reviews, photos
- **Authentication**: Bearer token

### 4. OpenTable API
- **Base URL**: `https://opentable.herokuapp.com/api`
- **Documentation**: [OpenTable API](https://opentable.herokuapp.com/)
- **Features**: Restaurant reservations, availability
- **Authentication**: No authentication required (public API)

### 5. TripAdvisor API
- **Base URL**: `https://api.content.tripadvisor.com/api/v1`
- **Documentation**: [TripAdvisor Content API](https://developer-tripadvisor.com/content-api/)
- **Features**: Restaurant reviews, photos, location data
- **Authentication**: API key

## Implementation Steps

### Step 1: Get API Keys
1. **Yemeksepeti**: Register at [developers.yemeksepeti.com](https://developers.yemeksepeti.com)
2. **Getir**: Contact Getir business development team
3. **Yelp**: Get API key from [Yelp Developer Console](https://www.yelp.com/developers/v3/manage_app)
4. **OpenTable**: No API key required
5. **TripAdvisor**: Register at [developer-tripadvisor.com](https://developer-tripadvisor.com)

### Step 2: Update Configuration
In `Models/IstanbulRestaurantAPI.swift`, update the API configuration:

```swift
// API Configuration
private let yemeksepetiAPIKey = "YOUR_YEMEKSEPETI_API_KEY"
private let getirAPIKey = "YOUR_GETIR_API_KEY"
private let yelpAPIKey = "YOUR_YELP_API_KEY"
private let tripAdvisorAPIKey = "YOUR_TRIPADVISOR_API_KEY"
```

### Step 3: Implement Real API Calls
Replace the mock API methods with real implementations:

```swift
private func fetchFromYemeksepeti(completion: @escaping () -> Void) {
    let urlString = "\(baseURL)/restaurants/istanbul"
    guard let url = URL(string: urlString) else {
        completion()
        return
    }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(yemeksepetiAPIKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
        defer { completion() }
        
        if let error = error {
            print("Yemeksepeti API error: \(error)")
            return
        }
        
        guard let data = data else { return }
        
        do {
            // Parse Yemeksepeti response format
            let response = try JSONDecoder().decode(YemeksepetiResponse.self, from: data)
            // Update restaurants array with real data
            self?.updateRestaurantsFromAPI(response.restaurants)
        } catch {
            print("Error parsing Yemeksepeti response: \(error)")
        }
    }.resume()
}
```

### Step 4: Handle Real Reservation APIs
Implement real reservation functionality:

```swift
func makeReservation(_ request: ReservationRequest) async throws -> ReservationResponse {
    // Choose appropriate API based on restaurant
    if let yemeksepetiRestaurant = getYemeksepetiRestaurant(id: request.restaurantId) {
        return try await makeYemeksepetiReservation(request)
    } else if let getirRestaurant = getGetirRestaurant(id: request.restaurantId) {
        return try await makeGetirReservation(request)
    } else {
        // Fallback to local reservation system
        return makeLocalReservation(request)
    }
}
```

## API Response Formats

### Yemeksepeti Restaurant Format
```json
{
  "restaurants": [
    {
      "id": "restaurant_id",
      "name": "Restaurant Name",
      "district": "Beşiktaş",
      "cuisine": "Turkish",
      "rating": 4.8,
      "price_range": "$$",
      "address": "Full address",
      "phone": "+90 212 xxx xx xx",
      "website": "https://restaurant.com",
      "hours": {
        "monday": "11:00-23:00",
        "tuesday": "11:00-23:00"
      },
      "amenities": ["Outdoor Seating", "Parking", "Credit Card"],
      "coordinates": {
        "latitude": 41.0082,
        "longitude": 28.9784
      }
    }
  ]
}
```

### Getir Restaurant Format
```json
{
  "data": [
    {
      "restaurant_id": "id",
      "restaurant_name": "Name",
      "neighborhood": "District",
      "cuisine_type": "Cuisine",
      "rating": 4.5,
      "price_level": 2,
      "address": "Address",
      "phone": "Phone",
      "operating_hours": "Hours",
      "features": ["Feature1", "Feature2"]
    }
  ]
}
```

## Error Handling

Implement proper error handling for API failures:

```swift
enum APIError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case rateLimitExceeded
    case authenticationFailed
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .authenticationFailed:
            return "Authentication failed. Please check your API key."
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}
```

## Rate Limiting

Implement rate limiting to respect API limits:

```swift
class RateLimiter {
    private var requestCounts: [String: (count: Int, resetTime: Date)] = [:]
    
    func canMakeRequest(for api: String) -> Bool {
        let now = Date()
        if let (count, resetTime) = requestCounts[api] {
            if now >= resetTime {
                requestCounts[api] = (1, now.addingTimeInterval(3600)) // 1 hour
                return true
            }
            return count < getRateLimit(for: api)
        } else {
            requestCounts[api] = (1, now.addingTimeInterval(3600))
            return true
        }
    }
    
    private func getRateLimit(for api: String) -> Int {
        switch api {
        case "yemeksepeti": return 1000 // per hour
        case "getir": return 500 // per hour
        case "yelp": return 5000 // per day
        default: return 100
        }
    }
}
```

## Caching Strategy

Implement caching to reduce API calls:

```swift
class RestaurantCache {
    private let cache = NSCache<NSString, CachedRestaurantData>()
    private let cacheExpiration: TimeInterval = 3600 // 1 hour
    
    func getCachedData(for key: String) -> [IstanbulRestaurant]? {
        guard let cached = cache.object(forKey: key as NSString) else { return nil }
        
        if Date().timeIntervalSince(cached.timestamp) < cacheExpiration {
            return cached.restaurants
        } else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
    }
    
    func cacheData(_ restaurants: [IstanbulRestaurant], for key: String) {
        let cachedData = CachedRestaurantData(restaurants: restaurants, timestamp: Date())
        cache.setObject(cachedData, forKey: key as NSString)
    }
}

struct CachedRestaurantData {
    let restaurants: [IstanbulRestaurant]
    let timestamp: Date
}
```

## Testing

### Test API Endpoints
```bash
# Test Yemeksepeti API
curl -H "Authorization: Bearer YOUR_API_KEY" \
     "https://api.yemeksepeti.com/restaurants/istanbul"

# Test Yelp API
curl -H "Authorization: Bearer YOUR_API_KEY" \
     "https://api.yelp.com/v3/businesses/search?location=Istanbul,Turkey&categories=restaurants"
```

### Test Reservation Flow
1. Search for restaurants
2. Select a restaurant
3. Choose date and time
4. Fill reservation form
5. Submit reservation
6. Verify confirmation

## Monitoring and Analytics

Track API usage and performance:

```swift
class APIMonitor {
    static let shared = APIMonitor()
    
    func trackAPICall(api: String, endpoint: String, responseTime: TimeInterval, success: Bool) {
        // Log to analytics service
        Analytics.logEvent("api_call", parameters: [
            "api": api,
            "endpoint": endpoint,
            "response_time": responseTime,
            "success": success
        ])
    }
    
    func trackError(api: String, error: Error) {
        Analytics.logError("api_error", error: error, parameters: [
            "api": api,
            "error_type": String(describing: type(of: error))
        ])
    }
}
```

## Security Considerations

1. **API Key Storage**: Store API keys securely in Keychain
2. **HTTPS Only**: Always use HTTPS for API calls
3. **Input Validation**: Validate all user inputs before sending to APIs
4. **Rate Limiting**: Implement client-side rate limiting
5. **Error Messages**: Don't expose sensitive information in error messages

## Fallback Strategy

When APIs are unavailable, fall back to local data:

```swift
func fetchRestaurants() {
    // Try real APIs first
    fetchFromAPIs { [weak self] success in
        if !success {
            // Fall back to local data
            self?.useLocalData()
        }
    }
}
```

## Next Steps

1. **Get API Keys**: Register with each service
2. **Implement Real Calls**: Replace mock methods
3. **Test Integration**: Verify data flow
4. **Add Error Handling**: Implement robust error handling
5. **Monitor Performance**: Track API response times
6. **Optimize Caching**: Reduce unnecessary API calls

## Support

- **Yemeksepeti**: [developers.yemeksepeti.com](https://developers.yemeksepeti.com)
- **Getir**: Business development team
- **Yelp**: [Yelp Support](https://www.yelp.com/support)
- **OpenTable**: [OpenTable API Support](https://opentable.herokuapp.com/)
- **TripAdvisor**: [TripAdvisor Developer Support](https://developer-tripadvisor.com)
