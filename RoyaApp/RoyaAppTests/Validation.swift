//
//  Validations.swift
//  ValidationTest
//
//  Created by Enrique Antonio Pires Rodríguez on 10/10/25.
//

import Foundation

// Helpers: moved validation out of the view because it lived in instance properties, which made testing harder.
enum Validation {
    static func passwordsMatch(_ a: String, _ b: String) -> Bool {
        !a.isEmpty && a == b
    }

    static func isValidEmailOrPhone(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let email = /.+@.+\..+/
        let phone = /^\d{10}$/
        return trimmed.wholeMatch(of: email) != nil
            || trimmed.wholeMatch(of: phone) != nil
    }
    
    static func isAdult(from date: Date) -> Bool {
        let calendar = Calendar.current
        let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: Date())!
        return date <= eighteenYearsAgo
    }
    
    static func isValidDate(_ date: Date) -> Bool {
        return date <= Date()
    }
    static func passwordStrength (_ password: String) -> Bool {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .punctuationCharacters.union(.symbols)) != nil { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        return score >= 3
    }
}
