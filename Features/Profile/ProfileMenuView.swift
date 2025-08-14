import SwiftUI

struct ProfileMenuView: View {
    @Binding var showProfileSetup: Bool
    @Binding var showAddFriends: Bool
    @Binding var isVisible: Bool
    let createTestData: () -> Void
    
    var body: some View {
        ZStack {
            // Light background to prevent tapping behind menu
            Color.black.opacity(0.1)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            
            // Menu content
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Spacer()
                        
                        Text("Menu")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isVisible = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .clipShape(
                        RoundedCorner(radius: 20, corners: [.topLeft])
                    )
                    
                    Divider()
                    
                    // Menu content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // MARK: - Profile Management
                            VStack(spacing: 0) {
                                // Section Header
                                HStack {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    Text("Profile Management")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color(.systemGray4))
                                        .offset(y: 0.5),
                                    alignment: .bottom
                                )
                                
                                // Section Items
                                VStack(spacing: 0) {
                                    Button {
                                        showProfileSetup = true
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isVisible = false
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "person.badge.plus")
                                                .foregroundColor(.orange)
                                                .frame(width: 24, height: 24)
                                            Text("Setup Profile")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Divider()
                                        .padding(.leading, 48)

                                    Button {
                                        showAddFriends = true
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isVisible = false
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "person.2.badge.gearshape")
                                                .foregroundColor(.purple)
                                                .frame(width: 24, height: 24)
                                            Text("Add Friends")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .padding(.leading, 48)
                                    
                                    Button {
                                        print("Edit Profile tapped")
                                    } label: {
                                        HStack {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.green)
                                                .frame(width: 24, height: 24)
                                            Text("Edit Profile")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 2)
                            
                            // MARK: - App Settings
                            VStack(spacing: 0) {
                                // Section Header
                                HStack {
                                    Image(systemName: "gearshape")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                    Text("App Settings")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color(.systemGray4))
                                        .offset(y: 0.5),
                                    alignment: .bottom
                                )
                                
                                // Section Items
                                VStack(spacing: 0) {
                                    Button {
                                        print("Notifications tapped")
                                    } label: {
                                        HStack {
                                            Image(systemName: "bell")
                                                .foregroundColor(.purple)
                                                .frame(width: 24, height: 24)
                                            Text("Notifications")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .padding(.leading, 48)
                                    
                                    Button {
                                        print("Privacy & Security tapped")
                                    } label: {
                                        HStack {
                                            Image(systemName: "lock.shield")
                                                .foregroundColor(.red)
                                                .frame(width: 24, height: 24)
                                            Text("Privacy & Security")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 2)
                            
                            // MARK: - Activity & History
                            VStack(spacing: 0) {
                                // Section Header
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    Text("Activity & History")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color(.systemGray4))
                                        .offset(y: 0.5),
                                    alignment: .bottom
                                )
                                
                                // Section Items
                                VStack(spacing: 0) {
                                    Button {
                                        print("View Booking History tapped")
                                    } label: {
                                        HStack {
                                            Image(systemName: "clock")
                                                .foregroundColor(.blue)
                                                .frame(width: 24, height: 24)
                                            Text("Booking History")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .padding(.leading, 48)
                                    
                                    Button {
                                        print("View Activity Log tapped")
                                    } label: {
                                        HStack {
                                            Image(systemName: "list.bullet")
                                                .foregroundColor(.orange)
                                                .frame(width: 24, height: 24)
                                            Text("Activity Log")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 2)
                            
                            // MARK: - Development Tools
                            VStack(spacing: 0) {
                                // Section Header
                                HStack {
                                    Image(systemName: "hammer.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    Text("Development Tools")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color(.systemGray4))
                                        .offset(y: 0.5),
                                    alignment: .bottom
                                )
                                
                                // Section Items
                                VStack(spacing: 0) {
                                    Button {
                                        createTestData()
                                    } label: {
                                        HStack {
                                            Image(systemName: "hammer.fill")
                                                .foregroundColor(.green)
                                                .frame(width: 24, height: 24)
                                            Text("Create Test Data")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .padding(.leading, 48)
                                    
                                    Button {
                                        print("Debug Information tapped")
                                    } label: {
                                        HStack {
                                            Image(systemName: "info.circle")
                                                .foregroundColor(.blue)
                                                .frame(width: 24, height: 24)
                                            Text("Debug Information")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
                        .frame(width: 350)
        .background(Color(.systemGray6))
        .clipShape(
            RoundedCorner(radius: 20, corners: [.topLeft, .bottomLeft])
        )
                .shadow(color: .black.opacity(0.1), radius: 5, x: -2, y: 0)
                .padding(.top, 50)
                .padding(.bottom, 150)
            }
        }
    }
}

// Custom shape for rounded corners on specific sides
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
