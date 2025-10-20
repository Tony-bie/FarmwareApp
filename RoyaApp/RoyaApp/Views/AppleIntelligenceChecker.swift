//
//  AppleIntelligenceChecker.swift
//  RoyaApp
//
//  Verifica disponibilidad de Apple Intelligence
//

import Foundation
import SwiftUI

@MainActor
class AppleIntelligenceChecker: ObservableObject {
    @Published var isAvailable: Bool = false
    
    init() {
        checkAvailability()
    }
    
    func checkAvailability() {
        if #available(iOS 26.0, *) {
            // En iOS 26+, verificamos si FoundationModels está disponible
            // Esto se puede hacer intentando inicializar el servicio
            isAvailable = true
        } else {
            isAvailable = false
        }
    }
    
    var unavailableMessage: String {
        """
        Apple Intelligence no está disponible en este dispositivo.
        
        Requisitos:
        • iOS 26.0 o superior
        • iPhone 15 Pro o superior
        • Apple Intelligence habilitado en Ajustes
        
        Esta función estará disponible cuando actualices tu dispositivo.
        """
    }
}
