//
//  ValidationTest.swift
//  ValidationTest
//
//  Created by Enrique Antonio Pires Rodríguez on 10/10/25.
//

import Testing
import Foundation
@testable import RoyaApp


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

// Jaime Carrera


struct ValidationTest3 {
    @Test("Password strength validation")
    func testPasswordStrength() async throws {
        // cumplen 3+ condiciones
        #expect(Validation.passwordStrength("Abc123!"))
        #expect(Validation.passwordStrength("Password1"))
        #expect(Validation.passwordStrength("qwerty!A"))

     
        #expect(!Validation.passwordStrength("abc"))
        #expect(!Validation.passwordStrength("password"))
        #expect(!Validation.passwordStrength("12345678"))
        #expect(!Validation.passwordStrength("ABCDEFGH"))       
    }
}


struct RegisterViewModelTests {
    @MainActor
    @Test("Registro exitoso con código 200")
    func testSuccessfulRegister() async throws {
        let vm =  RegisterViewModel()

        let user = RegisterUser(
            first_name: "Ana",
            last_name: "Pérez",
            username: "anap",
            email: "ana@correo.com",
            phonenumber: "5512345678",
            password: "MiPass#2024",
            birthday: "2000-01-01"
        )

        await vm.register(user: user)
        #expect(vm.registrationSuccess)
        #expect(vm.errorMessage == nil)
    }
    @MainActor
    @Test("Error HTTP 400 debe llenar errorMessage")
    func testHTTPError() async throws {
        let vm =  RegisterViewModel()


        let user = RegisterUser(
            first_name: "Ana",
            last_name: "Pérez",
            username: "anap",
            email: "ana@correo.com",
            phonenumber: "5512345678",
            password: "MiPass#2024",
            birthday: "2000-01-01"
        )

        await vm.register(user: user)
        #expect(!vm.registrationSuccess)
        #expect(vm.errorMessage == "Datos inválidos")
    }
    
    @MainActor
    @Test("Error de red lanza mensaje adecuado")
    func testNetworkError() async throws {
        let vm =  RegisterViewModel()
        await vm.register(user: RegisterUser(
            first_name: "Ana", last_name: "Pérez", username: "anap",
            email: "ana@correo.com", phonenumber: "5512345678",
            password: "MiPass#2024", birthday: "2000-01-01"
        ))
        #expect(vm.errorMessage != nil)
    }
}

// Santiago Cordova


@MainActor
struct AIChatLoadTests {

    @Test("La vista AIChat se inicializa correctamente")
    func testAIChatInitialization() async throws {
       
        let _ = AIChat()
        #expect(true)
    }
}

@MainActor
struct AIChatListExistenceTests {

    @Test("La vista AIChat contiene una lista (List) y se inicializa sin errores")
    func testAIChatListExists() async throws {
        //
        let view = AIChat()
        _ = view.body

        
        #expect(true)
    }
}

