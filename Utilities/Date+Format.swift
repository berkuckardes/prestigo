//
//  Date+Format.swift
//  prestigo
//
//  Created by Berk  on 8.08.2025.
//
import Foundation

extension Date {
    func timeString() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: self)
    }
    func dayTitle() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE, d MMM"
        return f.string(from: self)
    }
}
