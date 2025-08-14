import SwiftUI

// MARK: - Add Friends View
struct AddFriendsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: FirestoreSocialService
    
    @State private var searchText = ""
    @State private var searchResults: [UserProfile] = []
    @State private var isSearching = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search by name or email", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            searchUsers()
                        }
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                            searchResults = []
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Search Results
                if isSearching {
                    Spacer()
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.secondary)
                        
                        Text("No users found")
                            .font(.headline)
                        
                        Text("Try searching with a different name or email")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else if searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.badge.gearshape")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.secondary)
                        
                        Text("Find Friends")
                            .font(.headline)
                        
                        Text("Search for friends by their name or email address to connect with them")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(searchResults, id: \.id) { user in
                        HStack {
                            UserAvatar(
                                photoURL: user.photoURL,
                                displayName: user.displayName,
                                size: 50,
                                isVerified: user.isVerified
                            )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName)
                                    .font(.headline)
                                
                                if let city = user.city {
                                    Text(city)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button("Add") {
                                sendFriendRequest(to: user)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Add Friends")
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
    
    private func searchUsers() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        Task {
            do {
                let results = try await socialService.searchUsers(query: searchText)
                
                await MainActor.run {
                    isSearching = false
                    searchResults = results
                }
            } catch {
                await MainActor.run {
                    isSearching = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func sendFriendRequest(to user: UserProfile) {
        guard let userId = user.id else { return }
        
        Task {
            do {
                try await socialService.sendFriendRequest(to: userId)
                
                await MainActor.run {
                    // Remove from search results
                    searchResults.removeAll { $0.id == userId }
                    
                    // Show success message
                    // TODO: Add success feedback
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    AddFriendsView(socialService: FirestoreSocialService())
}
