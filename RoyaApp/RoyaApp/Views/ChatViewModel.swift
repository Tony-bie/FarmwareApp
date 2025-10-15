//
//  ChatViewModel.swift
//  RoyaApp
//
//  Created by Santiago Cordova on 01/10/25.
//

import Foundation
import Observation
import FoundationModels

@available(iOS 26.0, *)
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [String] = []
    @Published var isResponding = false
    
    private let session: LanguageModelSession

    init() {
        // Creamos la sesión con el modelo de lenguaje del sistema
        // y proporcionamos instrucciones personalizadas
        self.session = LanguageModelSession(
            instructions: "You are a helpful assistant that knows a lot about coffee plantations."
        )
    }
    
    func processMessage(_ input: String) async -> String {
        do {
            let response = try await session.respond(to: input)
            return response.content
        } catch {
            print("Error del modelo: \(error)")
            return "Perdón, no pude responder eso."
        }
    }
}

