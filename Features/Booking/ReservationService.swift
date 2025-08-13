//
//  ReservationService.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol ReservationService {
    func createReservation(venueId: String,
                           venueName: String,
                           slot: VenueSlot,
                           partySize: Int) async throws
}

final class FirestoreReservationService: ReservationService {
    func createReservation(venueId: String,
                           venueName: String,
                           slot: VenueSlot,
                           partySize: Int) async throws {

        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ReservationService",
                          code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }

        let data: [String: Any] = [
            "userId": uid,
            "venueId": venueId,
            "venueName": venueName,
            "slotId": slot.id,
            "slotStart": Timestamp(date: slot.startAt),
            "slotEnd": Timestamp(date: slot.endAt),
            "partySize": partySize,
            "status": "confirmed",
            "createdAt": Timestamp(date: Date())
        ]

        try await Firestore.firestore()
            .collection("reservations")
            .addDocument(data: data)

        print("✅ Reservation saved for user: \(uid)")
    }
}
