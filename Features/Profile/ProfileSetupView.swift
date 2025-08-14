import SwiftUI

struct ProfileSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthService
    
    @State private var displayName = ""
    @State private var bio = ""
    @State private var city = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.orange)
                        
                        Text("Complete Your Profile")
                            .font(.title2)
                            .bold()
                        
                        Text("Add some details to help friends recognize you")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                                        // Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your name", text: $displayName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio (Optional)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Tell us about yourself...", text: $bio, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("City (Optional)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Where are you located?", text: $city)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Profile Picture")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Button {
                                // TODO: Implement photo picker
                                print("Photo picker tapped")
                            } label: {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.blue)
                                    Text("Add Profile Picture")
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Submit Button
                    Button {
                        submitProfile()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle")
                            }
                            Text(isSubmitting ? "Setting up..." : "Complete Setup")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(displayName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 2)
                    }
                    .disabled(displayName.isEmpty || isSubmitting)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Profile Setup")
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
    
    private func submitProfile() {
        guard !displayName.isEmpty else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await auth.createUserProfile(
                    displayName: displayName,
                    bio: bio.isEmpty ? nil : bio,
                    city: city.isEmpty ? nil : city
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
    ProfileSetupView()
        .environmentObject(AuthService())
}
