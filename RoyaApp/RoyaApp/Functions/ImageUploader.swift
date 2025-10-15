//
//  ImageUploader.swift
//  RoyaApp
//
//  Created by David Ortega Muzquiz on 30/09/25.
//

import UIKit

struct ImageUploader {
    static func uploadImage(_ image: UIImage, etapa: String, comentario: String? = nil) async throws -> String {
        guard let url = URL(string: "http://127.0.0.1:8000/upload") else { throw URLError(.badURL) }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw URLError(.cannotDecodeContentData) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 1) Unique filename to avoid overwriting objects in the bucket
        let uniqueFilename = "image-\(UUID().uuidString).jpg"
        
        var body = Data()
        
        // Campo 'etapa'
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"etapa\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(etapa)\r\n".data(using: .utf8)!)
        
        // Campo 'comentario' si existe
        if let comentario = comentario {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"comentario\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(comentario)\r\n".data(using: .utf8)!)
        }
        
        // Archivo (usa el nombre único arriba)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(uniqueFilename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return json?["url"] as? String ?? ""
    }
}
