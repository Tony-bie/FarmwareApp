import Foundation
import SwiftUI

// Nuevo struct para mapear el JSON del backend
struct RegisterUser: Codable {
    let first_name: String
    let last_name: String
    let username: String
    let email: String?
    let phonenumber: String?
    let password: String
    let birthday: String
}

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var registrationSuccess = false
    @Published var errorMessage: String?

    func register(user: RegisterUser) async {
        guard let url = URL(string: "http://10.22.193.199:8000/register") else {
            errorMessage = "URL inválida"
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Respuesta inválida"
                return
            }

            if httpResponse.statusCode == 200 {
                registrationSuccess = true
            } else {
                let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                errorMessage = errorResponse?["detail"] ?? "Error desconocido"
            }
        } catch {
            errorMessage = "Error de red: \(error.localizedDescription)"
        }
    }
}
