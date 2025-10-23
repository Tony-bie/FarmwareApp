import Foundation
import SwiftUI

// Modelo que refleja exactamente la respuesta del backend
private struct BackendPhoto: Codable, Identifiable {
    var id: UUID           // UUID de la tabla 'photos' en el backend (Supabase)
    var etapa: String
    var img_url: String
    var date: Date?
    var comentario: String?
}

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var arrHistorial = [Historial]()
    
    // ISO8601 con fracciones de segundo
    private let iso8601WithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]
        return formatter
    }()
    
    // ISO8601 sin fracciones de segundo
    private let iso8601Basic: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        return formatter
    }()
    
    // Fallbacks comunes de Postgres/Supabase
    private lazy var fallbackDateFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // microsegundos + tz
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",    // milisegundos + tz
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",        // sin fracciones + tz
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",      // microsegundos sin tz
            "yyyy-MM-dd'T'HH:mm:ss.SSS",         // milisegundos sin tz
            "yyyy-MM-dd'T'HH:mm:ss"              // simple
        ]
        return formats.map {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = $0
            return df
        }
    }()
    
    // Formateador para mostrar títulos de día (coincide con HistoryView)
    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }()
    
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
        // Ajusta el host si cambias de entorno
        guard let url = URL(string: "http://10.22.193.199:8000/photos") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoder = JSONDecoder()
            // Maneja ISO8601 con y sin fracciones de segundo + algunos fallbacks
            decoder.dateDecodingStrategy = .custom { [iso8601WithFractional = self.iso8601WithFractional,
                                                      iso8601Basic = self.iso8601Basic,
                                                      fallbacks = self.fallbackDateFormatters] decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                if let d = iso8601WithFractional.date(from: dateString) { return d }
                if let d = iso8601Basic.date(from: dateString) { return d }
                for df in fallbacks {
                    if let d = df.date(from: dateString) { return d }
                }
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Formato de fecha inválido: \(dateString)"
                )
            }
            
            let decoded = try decoder.decode([BackendPhoto].self, from: data)
            print("✅ Decodificadas \(decoded.count) fotos")
            if let first = decoded.first {
                print("Ejemplo URL:", first.img_url)
            }
            
            // 1) Ordenar por fecha descendente (nil al final)
            let decodedSorted = decoded.sorted { a, b in
                switch (a.date, b.date) {
                case let (da?, db?): return da > db
                case (_?, nil): return true
                case (nil, _?): return false
                default: return a.id.uuidString > b.id.uuidString // fallback estable
                }
            }
            
            // 2) Agrupar por día y eliminar URLs duplicadas por día
            var imagesByDay = [Date: [String]]()
            var seenByDay = [Date: Set<String>]()
            var imagesWithoutDate = [String]()
            var seenWithoutDate = Set<String>()
            let calendar = Calendar.current
            
            for photo in decodedSorted {
                if let d = photo.date {
                    let day = calendar.startOfDay(for: d)
                    var seen = seenByDay[day] ?? Set<String>()
                    if !seen.contains(photo.img_url) {
                        imagesByDay[day, default: []].append(photo.img_url)
                        seen.insert(photo.img_url)
                        seenByDay[day] = seen
                    }
                } else {
                    if !seenWithoutDate.contains(photo.img_url) {
                        imagesWithoutDate.append(photo.img_url)
                        seenWithoutDate.insert(photo.img_url)
                    }
                }
            }
            
            // 3) Construir arreglo de Historial ordenado por fecha descendente
            var temp = [Historial]()
            for day in imagesByDay.keys.sorted(by: >) {
                let title = displayFormatter.string(from: day)
                let images = imagesByDay[day] ?? []
                temp.append(Historial(date: title, images: images))
            }
            
            // Opcional: agrega "Sin fecha" al final si existen
            if !imagesWithoutDate.isEmpty {
                temp.append(Historial(date: "Sin fecha", images: imagesWithoutDate))
            }
            
            self.arrHistorial = temp
            print("✅ Historial secciones: \(temp.count)")
        } catch {
            print("❌ Error decodificando JSON: \(error)")
            if let s = String(data: data, encoding: .utf8) {
                print("Payload recibido:\n\(s)")
            }
            throw error
        }
    }
}
