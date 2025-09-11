import Foundation
import SwiftUI

// Nuevo struct para mapear el JSON del backend
struct ImageData: Codable {
    let id: Int
    let filename: String
    let url: String
}

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var arrHistorial = [Historial]()
    
    init() {
        Task {
            do {
                try await loadAPI()
            } catch {
                print("Error cargando historial: \(error.localizedDescription)")
            }
        }
    }
    
    func loadAPI() async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/images") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            // Decodificamos como array de ImageData
            let decoded = try JSONDecoder().decode([ImageData].self, from: data)
            
            // Extraemos solo las URLs
            let urls = decoded.map { $0.url }
            
            // Agrupamos por fecha para simular historial
            var temp = [Historial]()
            var currentDate = 1
            for chunk in urls.chunked(into: 3) {
                let h = Historial(date: "Sep \(currentDate), 2025", images: chunk)
                temp.append(h)
                currentDate += 1
            }
            
            self.arrHistorial = temp
        } catch {
            print("Error decodificando JSON: \(error)")
            throw error
        }
    }
}

// Extensión para dividir arrays en "chunks"
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        var result: [[Element]] = []
        var chunk: [Element] = []
        for element in self {
            chunk.append(element)
            if chunk.count == size {
                result.append(chunk)
                chunk.removeAll()
            }
        }
        if !chunk.isEmpty { result.append(chunk) }
        return result
    }
}
