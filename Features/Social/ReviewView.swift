import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: FirestoreSocialService
    
    @State private var selectedVenue: Venue?
    @State private var rating = 5
    @State private var reviewText = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.yellow)
                        
                        Text("Write a Review")
                            .font(.title2)
                            .bold()
                        
                        Text("Share your experience with friends")
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
                    
                    // Rating
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rating")
                            .font(.headline)
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    rating = star
                                } label: {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(star <= rating ? .yellow : .gray)
                                }
                            }
                        }
                        
                        Text("\(rating) out of 5 stars")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Review Text
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Review")
                            .font(.headline)
                        
                        TextField("Share your experience...", text: $reviewText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(5...10)
                    }
                    
                    // Submit Button
                    Button {
                        submitReview()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "star.circle.fill")
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit Review")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedVenue == nil || reviewText.isEmpty ? Color.gray : Color.yellow)
                        .foregroundColor(selectedVenue == nil || reviewText.isEmpty ? .white : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(selectedVenue == nil || reviewText.isEmpty || isSubmitting)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Write Review")
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
    
    private func submitReview() {
        guard let venue = selectedVenue, !reviewText.isEmpty else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await socialService.createReview(
                    venueId: venue.id ?? "",
                    venueName: venue.name,
                    rating: rating,
                    reviewText: reviewText,
                    photos: nil
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
    ReviewView(socialService: FirestoreSocialService())
}
