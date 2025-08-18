import SwiftUI

struct ProfileMenuView: View {
    @Binding var showProfileSetup: Bool
    @Binding var showAddFriends: Bool
    @Binding var isVisible: Bool
    let createTestData: () -> Void
    
    // State for collapsible sections
    @State private var expandedSections: Set<String> = ["Profile Management"]
    @State private var showQuickActions = false
    @State private var selectedQuickAction: QuickAction?
    
    enum QuickAction: String, CaseIterable {
        case profile = "Profile"
        case friends = "Friends"
        case settings = "Settings"
        case history = "History"
        
        var icon: String {
            switch self {
            case .profile: return "person.circle"
            case .friends: return "person.2"
            case .settings: return "gearshape"
            case .history: return "clock"
            }
        }
        
        var color: Color {
            switch self {
            case .profile: return .blue
            case .friends: return .purple
            case .settings: return .gray
            case .history: return .green
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Enhanced background with blur effect
            Color.black.opacity(0.15)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture {
                    closeMenu()
                }
            
            // Menu content
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Enhanced Header with Quick Actions
                    VStack(spacing: 16) {
                        // Main Header
                        HStack {
                            Spacer()
                            
                            Text("Menu")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button {
                                closeMenu()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                                    .scaleEffect(1.1)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        
                        // Quick Actions Bar
                        if showQuickActions {
                            quickActionsBar
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        }
                    }
                    .clipShape(
                        RoundedCorner(radius: 20, corners: [.topLeft])
                    )
                    
                    Divider()
                    
                    // Enhanced Menu Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // MARK: - Profile Management (Enhanced)
                            collapsibleSection(
                                title: "Profile Management",
                                icon: "person.crop.circle.badge.plus",
                                iconColor: .blue,
                                isExpanded: expandedSections.contains("Profile Management")
                            ) {
                                VStack(spacing: 0) {
                                    menuItem(
                                        icon: "person.badge.plus",
                                        iconColor: .orange,
                                        title: "Setup Profile",
                                        action: {
                                            showProfileSetup = true
                                            closeMenu()
                                        }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "person.2.badge.gearshape",
                                        iconColor: .purple,
                                        title: "Add Friends",
                                        action: {
                                            showAddFriends = true
                                            closeMenu()
                                        }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "pencil",
                                        iconColor: .green,
                                        title: "Edit Profile",
                                        action: { print("Edit Profile tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "camera",
                                        iconColor: .pink,
                                        title: "Change Photo",
                                        action: { print("Change Photo tapped") }
                                    )
                                }
                            }
                            
                            // MARK: - App Settings (Enhanced)
                            collapsibleSection(
                                title: "App Settings",
                                icon: "gearshape",
                                iconColor: .gray,
                                isExpanded: expandedSections.contains("App Settings")
                            ) {
                                VStack(spacing: 0) {
                                    menuItem(
                                        icon: "bell",
                                        iconColor: .purple,
                                        title: "Notifications",
                                        action: { print("Notifications tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "lock.shield",
                                        iconColor: .red,
                                        title: "Privacy & Security",
                                        action: { print("Privacy & Security tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "moon",
                                        iconColor: .indigo,
                                        title: "Appearance",
                                        action: { print("Appearance tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "globe",
                                        iconColor: .teal,
                                        title: "Language",
                                        action: { print("Language tapped") }
                                    )
                                }
                            }
                            
                            // MARK: - Activity & History (Enhanced)
                            collapsibleSection(
                                title: "Activity & History",
                                icon: "clock.arrow.circlepath",
                                iconColor: .green,
                                isExpanded: expandedSections.contains("Activity & History")
                            ) {
                                VStack(spacing: 0) {
                                    menuItem(
                                        icon: "clock",
                                        iconColor: .blue,
                                        title: "Booking History",
                                        action: { print("View Booking History tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "list.bullet",
                                        iconColor: .orange,
                                        title: "Activity Log",
                                        action: { print("View Activity Log tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "star",
                                        iconColor: .yellow,
                                        title: "My Reviews",
                                        action: { print("My Reviews tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "heart",
                                        iconColor: .red,
                                        title: "Favorites",
                                        action: { print("Favorites tapped") }
                                    )
                                }
                            }
                            
                            // MARK: - Social & Connections (New Section)
                            collapsibleSection(
                                title: "Social & Connections",
                                icon: "network",
                                iconColor: .purple,
                                isExpanded: expandedSections.contains("Social & Connections")
                            ) {
                                VStack(spacing: 0) {
                                    menuItem(
                                        icon: "person.2",
                                        iconColor: .blue,
                                        title: "Friends List",
                                        action: { print("Friends List tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "message",
                                        iconColor: .green,
                                        title: "Messages",
                                        action: { print("Messages tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "person.badge.plus",
                                        iconColor: .orange,
                                        title: "Friend Requests",
                                        action: { print("Friend Requests tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "chart.bar",
                                        iconColor: .teal,
                                        title: "Social Stats",
                                        action: { print("Social Stats tapped") }
                                    )
                                }
                            }
                            
                            // MARK: - Development Tools (Enhanced)
                            collapsibleSection(
                                title: "Development Tools",
                                icon: "hammer.fill",
                                iconColor: .green,
                                isExpanded: expandedSections.contains("Development Tools")
                            ) {
                                VStack(spacing: 0) {
                                    menuItem(
                                        icon: "hammer.fill",
                                        iconColor: .green,
                                        title: "Create Test Data",
                                        action: { createTestData() }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "info.circle",
                                        iconColor: .blue,
                                        title: "Debug Information",
                                        action: { print("Debug Information tapped") }
                                    )
                                    
                                    Divider().padding(.leading, 48)
                                    
                                    menuItem(
                                        icon: "arrow.clockwise",
                                        iconColor: .purple,
                                        title: "Reset App Data",
                                        action: { print("Reset App Data tapped") }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
                .frame(width: 380)
                .background(Color(.systemGray6))
                .clipShape(
                    RoundedCorner(radius: 20, corners: [.topLeft, .bottomLeft])
                )
                .overlay(
                    RoundedCorner(radius: 20, corners: [.topLeft, .bottomLeft])
                        .stroke(Color(.systemGray5), lineWidth: 0.5)
                )
                .padding(.top, 50)
                .padding(.bottom, 150)
            }
        }
        .onAppear {
            // Animate sections in sequence
            animateSectionsIn()
        }
    }
    
    // MARK: - Quick Actions Bar
    private var quickActionsBar: some View {
        HStack(spacing: 12) {
            ForEach(QuickAction.allCases, id: \.self) { action in
                Button {
                    selectedQuickAction = action
                    performQuickAction(action)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: action.icon)
                            .font(.title2)
                            .foregroundColor(action.color)
                        Text(action.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 60, height: 50)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(action.color.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(selectedQuickAction == action ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedQuickAction)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Collapsible Section
    private func collapsibleSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        isExpanded: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // Section Header (Tappable)
            Button {
                toggleSection(title)
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.title2)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
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
            }
            .buttonStyle(PlainButtonStyle())
            
            // Section Content
            if isExpanded {
                content()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // MARK: - Menu Item
    private func menuItem(
        icon: String,
        iconColor: Color,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Functions
    private func toggleSection(_ title: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if expandedSections.contains(title) {
                expandedSections.remove(title)
            } else {
                expandedSections.insert(title)
            }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func closeMenu() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false
        }
    }
    
    private func performQuickAction(_ action: QuickAction) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        switch action {
        case .profile:
            showProfileSetup = true
            closeMenu()
        case .friends:
            showAddFriends = true
            closeMenu()
        case .settings:
            expandedSections.insert("App Settings")
        case .history:
            expandedSections.insert("Activity & History")
        }
    }
    
    private func animateSectionsIn() {
        // Animate sections appearing with slight delays
        for (index, section) in ["Profile Management", "App Settings", "Activity & History", "Social & Connections", "Development Tools"].enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    if section == "Profile Management" {
                        expandedSections.insert(section)
                    }
                }
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
