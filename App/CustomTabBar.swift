//
//  CustomTabBar.swift
//  prestigo
//
//  Created by Berk  on 12.08.2025.
//

// App/CustomTabBar.swift
import SwiftUI

struct CustomTabBar: View {
    @Binding var selection: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(tab: tab, isSelected: selection == tab) {
                    selection = tab
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .shadow(color: .black.opacity(0.05), radius: 1, y: 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: selection)
    }
}

private struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.8))
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

                Text(tab.title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isSelected ? Color.white : Color.white.opacity(0.8))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .minimumScaleFactor(0.85)
                    .opacity(isSelected ? 1.0 : 0.9)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

