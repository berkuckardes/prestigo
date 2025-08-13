//
//  VenueSlot.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import Foundation

struct VenueSlot: Identifiable, Hashable {
    let id: String
    let venueId: String
    let startAt: Date
    let endAt: Date
    let capacity: Int
    var available: Int
}

enum SlotDummyData {
    /// Generate 30-min slots for a date window, purely local for now
    static func generate(venueId: String, for day: Date) -> [VenueSlot] {
        var slots: [VenueSlot] = []
        let calendar = Calendar.current
        guard
            let startOfDay = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: day),
            let endOfDay   = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: day)
        else { return slots }

        var t = startOfDay
        while t < endOfDay {
            let end = calendar.date(byAdding: .minute, value: 30, to: t)!
            let id  = "\(venueId)_\(Int(t.timeIntervalSince1970))"
            let cap = 10
            let avail = Int.random(in: 0...cap) // demo only
            slots.append(VenueSlot(id: id, venueId: venueId, startAt: t, endAt: end, capacity: cap, available: avail))
            t = end
        }
        return slots
    }
}
