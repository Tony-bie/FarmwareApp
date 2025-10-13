//
//  LoginModel.swift
//  RoyaApp
//
//  Created by Alumno on 03/10/25.
//

import Foundation

struct LoginRequest: Codable{
    let identifier: String
    let password: String
}

struct LoginResponse: Codable {
    struct User: Codable { let id_user: Int }
    let user: User?
    let message: String?
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
                if let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data),
                   let id = decoded.user?.id_user {
                    AppSession.shared.userId = id
                    KeychainHelper.standard.set("\(id)", forKey: "user_id")
                    isLoggedIn = true
                } else {
                    errorMessage = "No se pudo leer el usuario"
                }
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

final class AppSession: ObservableObject {
    static let shared = AppSession()
    @Published var userId: Int? = nil
    private init() {
        if let s = KeychainHelper.standard.get("user_id"), let id = Int(s) {
            userId = id
        }
    }
    func logout() {
            userId = nil
            KeychainHelper.standard.delete("user_id")
    }
}

final class KeychainHelper {
    static let standard = KeychainHelper()
    func set(_ value: String, forKey key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var ref: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &ref)
        if let data = ref as? Data { return String(data: data, encoding: .utf8) }
        return nil
    }
    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

