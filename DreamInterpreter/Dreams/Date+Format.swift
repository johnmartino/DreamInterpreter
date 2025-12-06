//
//  Date+Format.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/6/25.
//

import Foundation

extension Date {
    var dateStamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
