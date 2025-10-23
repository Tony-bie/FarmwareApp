//
//  ConfigModel.swift
//  RoyaApp
//
//  Created by Enrique Antonio Pires Rodríguez on 07/10/25.
// .

import Foundation
import SwiftUI

struct UpdateData: Codable{
    let first_name: String?
    let last_name: String?
    let username: String?
    let email: String?
    let phonenumber: String?
    let current_password: String?
    let new_password: String?
    let confirm_password: String?
}

struct DeleteIn: Codable {
    let current_password: String
}

@MainActor
class ConfigModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isUpdated: Bool = false
    @Published var isDeleted: Bool = false
    
    func saveChanges(userId: Int, data: UpdateData) async {
        guard let url = URL(string: "http://10.22.193.199:8000/users/\(userId)") else {
            errorMessage = "URL inválida"
            return
        }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONEncoder().encode(data)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Respuesta inválida"
                return
            }
            
            if httpResponse.statusCode == 200 {
                isUpdated = true
            } else {
                let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                errorMessage = errorResponse?["detail"] ?? "Error desconocido"
            }        } catch {
                errorMessage = "Error al actualizar los datos"
            }
    }
    func deleteAccount(userId: Int, delete: DeleteIn) async {
        guard let url = URL(string: "http://10.22.193.199:8000/users/\(userId)") else {
            errorMessage = "URL inválida"
            return
        }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            let jsonData = try JSONEncoder().encode(delete)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Respuesta inválida"
                return
            }
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 204{
                isDeleted = true
            } else {
                let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                errorMessage = errorResponse?["detail"] ?? "No se pudo eliminar la cuenta"
            }
        } catch {
            errorMessage = "Error al eliminar la cuenta"
        }
    }
}
