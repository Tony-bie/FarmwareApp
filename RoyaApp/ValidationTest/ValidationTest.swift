//
//  ValidationTest.swift
//  ValidationTest
//
//  Created by Enrique Antonio Pires Rodríguez on 10/10/25.
//

import Testing
import Foundation

//By Enrique Antonio Pires
struct ValidationTest {
    @Test("Password match") func testPassword()  async throws{
        #expect(Validation.passwordsMatch("abc", "abc"))
        #expect(!Validation.passwordsMatch("abc", "def"))
    }
    @Test("Email and phone number") func emailPhoneTest()  async throws{
        #expect(Validation.isValidEmailOrPhone("hola@tec.com"))
        #expect(Validation.isValidEmailOrPhone("1312345678"))
        #expect(!Validation.isValidEmailOrPhone("hola"))
        #expect(!Validation.isValidEmailOrPhone("123"))
    }
}

// By Paloma Belenguer




struct ValidationTest2 {

    @Test("Valid date (no future dates)")
    func testValidDate() async throws {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        #expect(Validation.isValidDate(today))
        #expect(Validation.isValidDate(yesterday))
        #expect(!Validation.isValidDate(tomorrow))
    }

    @Test("Adult age (≥18 years)")
    func testAdultAge() async throws {
        let calendar = Calendar.current
        let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: Date())!
        let nineteenYearsAgo = calendar.date(byAdding: .year, value: -19, to: Date())!
        let seventeenYearsAgo = calendar.date(byAdding: .year, value: -17, to: Date())!

        #expect(Validation.isAdult(from: eighteenYearsAgo))
        #expect(Validation.isAdult(from: nineteenYearsAgo))
        #expect(!Validation.isAdult(from: seventeenYearsAgo))
    }
}



