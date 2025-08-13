// Features/Booking/SlotPickerView.swift


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SlotPickerView: View {
    let venueId: String
    let venueName: String

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var days: [Date] = []
    @State private var slots: [VenueSlot] = []

    // Reservation UI state
    @State private var showSheet = false
    @State private var selectedSlot: VenueSlot?
    @State private var partySize = 2
    @State private var alertMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            DaySelectorView(
                days: days,
                selectedDate: $selectedDate,
                onSelect: { day in
                    selectedDate = day
                    loadSlots()
                }
            )

            List {
                ForEach(slots, id: \.id) { slot in
                    SlotRow(slot: slot) {
                        guard slot.available > 0 else { return }
                        selectedSlot = slot
                        partySize = min(max(1, partySize), slot.available)
                        showSheet = true
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Slots · \(venueName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            configureDays()
            loadSlots()
        }
        .sheet(isPresented: $showSheet) {
            let availableNow = selectedSlot.flatMap { s in
                slots.first(where: { $0.id == s.id })?.available ?? s.available
            } ?? 0

            ReservationSheet(
                venueName: venueName,
                slot: selectedSlot,
                partySize: $partySize,
                availableNow: availableNow,
                onClose: { showSheet = false },
                onConfirm: { confirmReservation() }
            )
        }
        .alert(
            alertMessage ?? "",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )
        ) { Button("OK") { alertMessage = nil } }
    }

    private func configureDays() {
        guard days.isEmpty else { return }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
        selectedDate = days.first ?? start
    }

    private func loadSlots() {
        // Local dummy data for now. Replace with Firestore fetch later.
        slots = SlotDummyData.generate(venueId: venueId, for: selectedDate)
    }

    /// Confirm with re‑validation + optimistic UI; sheet closes immediately.
    private func confirmReservation() {
        guard let s = selectedSlot,
              let idx = slots.firstIndex(where: { $0.id == s.id }) else {
            showSheet = false
            return
        }

        // Re‑validate against freshest availability
        let latestAvail = slots[idx].available
        guard latestAvail > 0 else {
            alertMessage = "This time slot just became full."
            return
        }
        guard partySize <= latestAvail else {
            alertMessage = "Only \(latestAvail) seats left for this time."
            partySize = latestAvail
            return
        }

        // Optimistic local update and dismiss sheet immediately
        updateSlotAvailability(slotId: s.id, by: partySize)
        showSheet = false

        // Persist to Firestore in background; rollback on failure
        Task {
            do {
                let service = FirestoreReservationService()
                try await service.createReservation(
                    venueId: venueId,
                    venueName: venueName,
                    slot: s,
                    partySize: partySize
                )
            } catch {
                updateSlotAvailability(slotId: s.id, by: -partySize)
                alertMessage = "Couldn’t save reservation: \(error.localizedDescription)"
            }
        }
    }

    /// Centralized availability updater (swap body with Firestore transaction for Option 2)
    private func updateSlotAvailability(slotId: String, by amount: Int) {
        if let index = slots.firstIndex(where: { $0.id == slotId }) {
            var newVal = slots[index].available - amount
            if newVal < 0 { newVal = 0 }
            slots[index].available = newVal
        }
    }
}

// MARK: - Subviews

struct DaySelectorView: View {
    let days: [Date]
    @Binding var selectedDate: Date
    var onSelect: (Date) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Button { onSelect(day) } label: {
                        VStack {
                            Text(day.dayTitle()).font(.caption).bold()
                            Text(Calendar.current.isDateInToday(day) ? "Today" : "")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(day == selectedDate
                                      ? Color.gray.opacity(0.2)
                                      : Color.gray.opacity(0.08))
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct SlotRow: View {
    let slot: VenueSlot
    var onReserve: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(slot.startAt.timeString()) – \(slot.endAt.timeString())")
                    .font(.headline)
                Text("Available \(slot.available)/\(slot.capacity)")
                    .font(.subheadline)
                    .foregroundColor(slot.available > 0 ? Color.secondary : Color.red)
            }
            Spacer()
            Button(action: onReserve) {
                Text(slot.available > 0 ? "Reserve" : "Full")
            }
            .buttonStyle(.borderedProminent)
            .disabled(slot.available == 0)
        }
        .padding(.vertical, 4)
    }
}

/// Reservation Sheet
private struct ReservationSheet: View {
    let venueName: String
    let slot: VenueSlot?
    @Binding var partySize: Int
    let availableNow: Int
    var onClose: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let s = slot {
                    VStack(spacing: 6) {
                        Text(venueName).font(.headline)
                        Text("\(s.startAt.timeString()) – \(s.endAt.timeString())")
                            .foregroundStyle(.secondary)
                        Text("Available now: \(availableNow)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onAppear {
                        if partySize > availableNow { partySize = max(1, availableNow) }
                    }
                    .onChange(of: availableNow) { newAvail in
                        if partySize > newAvail { partySize = max(1, newAvail) }
                    }
                }

                Stepper("Party size: \(partySize)",
                        value: $partySize,
                        in: 1...max(1, availableNow))

                Button("Confirm Reservation", action: onConfirm)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(availableNow == 0)

                Spacer()
            }
            .padding()
            .navigationTitle("Reserve")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}





