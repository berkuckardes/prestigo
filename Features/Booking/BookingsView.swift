import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct BookingsView: View {
    @Binding var selectedTab: Tab
    @State private var reservations: [Reservation] = []
    @State private var loading = true
    @State private var errorMessage: String?
    @State private var selectedFilter: BookingFilter = .upcoming
    @State private var showingNewBooking = false
    
    enum BookingFilter: String, CaseIterable {
        case upcoming = "Upcoming"
        case past = "Past"
        case all = "All"
        
        var icon: String {
            switch self {
            case .upcoming: return "calendar.badge.plus"
            case .past: return "calendar.badge.clock"
            case .all: return "calendar"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    headerSection
                    
                    // Filter tabs
                    filterTabs
                    
                    // Content
                    if loading {
                        loadingView
                    } else if let errorMessage = errorMessage {
                        errorView(message: errorMessage)
                    } else if filteredReservations.isEmpty {
                        emptyStateView
                    } else {
                        reservationsList
                    }
                }
            }
            .navigationTitle("Bookings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewBooking = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                fetchReservations()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Stats cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Upcoming",
                    value: "\(upcomingCount)",
                    icon: "calendar.badge.plus",
                    color: .blue
                )
                
                StatCard(
                    title: "Total",
                    value: "\(reservations.count)",
                    icon: "calendar",
                    color: .green
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Filter Tabs
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(BookingFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        action: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Reservations List
    private var reservationsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredReservations) { reservation in
                    ReservationCard(
                        reservation: reservation,
                        onExploreVenues: { exploreVenues() },
                        onViewDetails: { viewBookingDetails(reservation) }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading your bookings...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                fetchReservations()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No \(selectedFilter.rawValue.lowercased()) bookings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start exploring venues and make your first reservation!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Explore Venues") {
                exploreVenues()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    private var upcomingCount: Int {
        reservations.filter { $0.slotStart > Date() }.count
    }
    
    private var filteredReservations: [Reservation] {
        switch selectedFilter {
        case .upcoming:
            return reservations.filter { $0.slotStart > Date() }
        case .past:
            return reservations.filter { $0.slotStart < Date() }
        case .all:
            return reservations
        }
    }
    
    // MARK: - Actions
    private func exploreVenues() {
        // Switch to explore tab
        selectedTab = .explore
        print("Switching to explore tab...")
    }
    
    private func viewBookingDetails(_ reservation: Reservation) {
        // Navigate to booking details
        print("Viewing details for booking: \(reservation.venueName)")
        // You can implement navigation to a detailed view here
    }
    
    // MARK: - Data Fetching
    private func fetchReservations() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user signed in"
            self.loading = false
            return
        }
        
        loading = true
        
        Firestore.firestore()
            .collection("reservations")
            .whereField("userId", isEqualTo: uid)
            .order(by: "slotStart", descending: false)
            .addSnapshotListener { snapshot, error in
                loading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.reservations = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Reservation.self)
                } ?? []
            }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Filter Tab Component
struct FilterTab: View {
    let filter: BookingsView.BookingFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: filter.icon)
                    .font(.system(size: 16, weight: .medium))
                Text(filter.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.blue : Color(.systemGray6)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Reservation Card Component
struct ReservationCard: View {
    let reservation: Reservation
    let onExploreVenues: () -> Void
    let onViewDetails: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with venue name and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reservation.venueName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(reservation.status.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Date and time
                VStack(alignment: .trailing, spacing: 4) {
                    Text(reservation.slotStart, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(reservation.slotStart, style: .time) - \(reservation.slotEnd, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Details
            HStack(spacing: 20) {
                DetailItem(
                    icon: "person.2",
                    title: "Party Size",
                    value: "\(reservation.partySize)"
                )
                
                DetailItem(
                    icon: "clock",
                    title: "Duration",
                    value: durationText
                )
                
                DetailItem(
                    icon: "location.circle",
                    title: "Venue ID",
                    value: reservation.venueId.prefix(8).description
                )
            }
            
            // Actions
            HStack(spacing: 12) {
                Button("View Details") {
                    onViewDetails()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                if reservation.slotStart > Date() {
                    Button("Cancel") {
                        // Cancel reservation
                        print("Canceling booking for: \(reservation.venueName)")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        switch reservation.status.lowercased() {
        case "confirmed": return .green
        case "pending": return .orange
        case "cancelled": return .red
        default: return .gray
        }
    }
    
    private var durationText: String {
        let duration = reservation.slotEnd.timeIntervalSince(reservation.slotStart)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Detail Item Component
struct DetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Reservation Model
struct Reservation: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var venueId: String
    var venueName: String
    var slotId: String
    var slotStart: Date
    var slotEnd: Date
    var partySize: Int
    var status: String
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case venueId
        case venueName
        case slotId
        case slotStart
        case slotEnd
        case partySize
        case status
        case createdAt
    }
}
