import SwiftUI

struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: FirestoreSocialService
    
    @State private var selectedVenue: Venue?
    @State private var checkInMessage = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.green)
                        
                        Text("Check In")
                            .font(.title2)
                            .bold()
                        
                        Text("Let your friends know where you are")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Venue Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Venue")
                            .font(.headline)
                        
                        if let venue = selectedVenue {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(venue.name)
                                    .font(.title3)
                                    .bold()
                                
                                Text(venue.category)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Button("Change Venue") {
                                    self.selectedVenue = nil
                                }
                                .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Button {
                                // TODO: Navigate to venue picker
                                print("Select venue tapped")
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Text("Select a Venue")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    
                    // Message
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Message (Optional)")
                            .font(.headline)
                        
                        TextField("What's happening?", text: $checkInMessage, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Submit Button
                    Button {
                        submitCheckIn()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "location.circle.fill")
                            }
                            Text(isSubmitting ? "Checking in..." : "Check In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedVenue == nil ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(selectedVenue == nil || isSubmitting)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitCheckIn() {
        guard let venue = selectedVenue else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await socialService.createCheckIn(
                    venueId: venue.id ?? "",
                    venueName: venue.name,
                    venueCategory: venue.category,
                    caption: checkInMessage.isEmpty ? nil : checkInMessage,
                    photos: nil,
                    partySize: nil
                )
                
                await MainActor.run {
                    isSubmitting = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    CheckInView(socialService: FirestoreSocialService())
}
