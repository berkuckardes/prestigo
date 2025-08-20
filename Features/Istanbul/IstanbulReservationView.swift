import SwiftUI

struct IstanbulReservationView: View {
    let restaurant: IstanbulRestaurant
    @StateObject private var reservationService = IstanbulRestaurantService()
    
    @State private var selectedDate = Date()
    @State private var selectedTime = ""
    @State private var partySize = 2
    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var customerEmail = ""
    @State private var specialRequests = ""
    @State private var showingReservationSheet = false
    @State private var availableSlots: [ReservationSlot] = []
    @State private var loadingSlots = false
    @State private var reservationResult: ReservationResponse?
    @State private var showingResult = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Restaurant Header
                restaurantHeader
                
                // Date Selection
                dateSelectionSection
                
                // Time Slots
                timeSlotsSection
                
                // Reservation Form
                reservationFormSection
                
                // Book Button
                bookButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .navigationTitle("Make Reservation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAvailableSlots()
        }
        .sheet(isPresented: $showingReservationSheet) {
            reservationConfirmationSheet
        }
        .alert("Reservation Result", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            if let result = reservationResult {
                Text(result.message)
            }
        }
    }
    
    // MARK: - Restaurant Header
    private var restaurantHeader: some View {
        VStack(spacing: 16) {
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
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Text(restaurant.district)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(restaurant.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                HStack {
                    Label("\(restaurant.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    Text(restaurant.priceRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Date Selection
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Date")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<14, id: \.self) { dayOffset in
                        let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        
                        Button {
                            selectedDate = date
                            loadAvailableSlots()
                        } label: {
                            VStack(spacing: 8) {
                                Text(calendar.component(.day, from: date).description)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text(calendar.veryShortWeekdaySymbols[calendar.component(.weekday, from: date) - 1])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 60, height: 80)
                            .background(isSelected ? Color.blue : Color(.systemGray6))
                            .foregroundColor(isSelected ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Time Slots
    private var timeSlotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Times")
                .font(.headline)
                .fontWeight(.semibold)
            
            if loadingSlots {
                HStack {
                    ProgressView()
                    Text("Loading available times...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if availableSlots.isEmpty {
                Text("No available times for this date")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(availableSlots.filter { $0.isAvailable }) { slot in
                        Button {
                            selectedTime = slot.time
                        } label: {
                            VStack(spacing: 4) {
                                Text(slot.time)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("\(slot.availableSeats) seats")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTime == slot.time ? Color.blue : Color(.systemGray6))
                            .foregroundColor(selectedTime == slot.time ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Reservation Form
    private var reservationFormSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reservation Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Party Size
                HStack {
                    Text("Party Size")
                    Spacer()
                    Picker("Party Size", selection: $partySize) {
                        ForEach(1...10, id: \.self) { size in
                            Text("\(size)").tag(size)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Customer Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Enter your name", text: $customerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Customer Phone
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Enter your phone number", text: $customerPhone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                }
                
                // Customer Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Enter your email", text: $customerEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Special Requests
                VStack(alignment: .leading, spacing: 8) {
                    Text("Special Requests (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Any special requests?", text: $specialRequests, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Book Button
    private var bookButton: some View {
        Button {
            makeReservation()
        } label: {
            HStack {
                if reservationService.loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "calendar.badge.plus")
                }
                
                Text("Book Reservation")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canMakeReservation ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canMakeReservation || reservationService.loading)
        .padding(.top, 8)
    }
    
    // MARK: - Reservation Confirmation Sheet
    private var reservationConfirmationSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let result = reservationResult {
                    VStack(spacing: 20) {
                        Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(result.success ? .green : .red)
                        
                        Text(result.success ? "Reservation Confirmed!" : "Reservation Failed")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(result.message)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if let confirmationCode = result.confirmationCode {
                            VStack(spacing: 8) {
                                Text("Confirmation Code")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(confirmationCode)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                Button("Done") {
                    showingReservationSheet = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
            .navigationTitle("Reservation Result")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    private var canMakeReservation: Bool {
        !customerName.isEmpty && 
        !customerPhone.isEmpty && 
        !customerEmail.isEmpty && 
        !selectedTime.isEmpty
    }
    
    // MARK: - Methods
    private func loadAvailableSlots() {
        loadingSlots = true
        
        Task {
            do {
                let slots = try await reservationService.getAvailableSlots(for: restaurant.id, date: selectedDate)
                await MainActor.run {
                    availableSlots = slots
                    loadingSlots = false
                }
            } catch {
                await MainActor.run {
                    loadingSlots = false
                }
            }
        }
    }
    
    private func makeReservation() {
        guard !selectedTime.isEmpty else { return }
        
        let request = ReservationRequest(
            restaurantId: restaurant.id,
            date: selectedDate,
            time: selectedTime,
            partySize: partySize,
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: customerEmail,
            specialRequests: specialRequests.isEmpty ? nil : specialRequests
        )
        
        Task {
            do {
                let result = try await reservationService.makeReservation(request)
                await MainActor.run {
                    reservationResult = result
                    showingResult = true
                    if result.success {
                        showingReservationSheet = true
                    }
                }
            } catch {
                await MainActor.run {
                    reservationResult = ReservationResponse(
                        success: false,
                        reservationId: nil,
                        message: "Error: \(error.localizedDescription)",
                        confirmationCode: nil
                    )
                    showingResult = true
                }
            }
        }
    }
}
