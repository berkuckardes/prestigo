//
//  PrestigeBadge.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import SwiftUI

struct PrestigeBadge: View {
    let level: String // bronze/silver/gold
    var body: some View {
        Text(level.capitalized)
            .font(.caption).bold()
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch level.lowercased() {
        case "gold": return .yellow
        case "silver": return .gray
        case "bronze": return .brown
        default: return .blue
        }
    }
}
