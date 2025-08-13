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
        HStack(spacing: 12) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(tab: tab, isSelected: selection == tab) {
                    selection = tab
                }
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.12)) // Soft light blue
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.blue.opacity(0.15), radius: 10, y: 4) // blue-tinted shadow
        .animation(.easeInOut(duration: 0.2), value: selection)
    }
}

private struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? Color.blue : Color.primary.opacity(0.6))

                if isSelected {
                    Text(tab.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.blue)              // Soft blue text when selected
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .minimumScaleFactor(0.85)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, isSelected ? 14 : 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

