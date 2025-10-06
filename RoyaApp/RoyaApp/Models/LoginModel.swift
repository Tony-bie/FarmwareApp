//
//  LoginModel.swift
//  RoyaApp
//
//  Created by Alumno on 03/10/25.
//

import Foundation

struct LoginRequest: Codable{
    let email: String
    let password: String
}

@MainActor
class LoginModel: ObservableObject{
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?

    
    func login(user: LoginRequest) async{
        
        errorMessage = nil
        isLoggedIn = false
        guard let url = URL(string: "http://127.0.0.1:8000/login") else {
            errorMessage = "URL invalida"
            return }
        do{
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Error de autenticacion"
                return
            }
            
            print("HTTP:", httpResponse.statusCode)
            print("Body:", String(data: data, encoding: .utf8) ?? "<sin texto>")
            
            if httpResponse.statusCode == 200 {
                isLoggedIn = true
            } else {
                if let err = try? JSONDecoder().decode([String:String].self, from: data),
                   let detail = err["detail"]{
                    errorMessage = detail
                } else{
                    errorMessage = "Error de autenticación(\(httpResponse.statusCode))"
                }
            }
        } catch {
            errorMessage = "Error de red: \(error.localizedDescription)"
        }
    }
}
