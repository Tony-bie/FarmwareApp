import Foundation
import CoreLocation

// MARK: - Respuesta Open-Meteo (current)
struct OpenMeteoResponse: Decodable {
    struct Current: Decodable {
        let time: String
        let temperature_2m: Double
        let relative_humidity_2m: Double?
        let wind_speed_10m: Double?
    }
    let latitude: Double
    let longitude: Double
    let current: Current
}

enum WeatherError: Error { case badURL, badResponse }

final class WeatherService {
    func fetch(lat: Double, lon: Double) async throws -> OpenMeteoResponse {
        var comps = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        comps.queryItems = [
            .init(name: "latitude", value: "\(lat)"),
            .init(name: "longitude", value: "\(lon)"),
            .init(name: "current", value: "temperature_2m,relative_humidity_2m,wind_speed_10m"),
            .init(name: "timezone", value: "auto")
        ]
        guard let url = comps.url else { throw WeatherError.badURL }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw WeatherError.badResponse }
        return try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
    }
}

@MainActor
final class WeatherModel: ObservableObject {
    @Published var temperature: Double?
    @Published var humidity: Double?
    @Published var windSpeed: Double?   
    @Published var placeName: String?
    @Published var errorMessage: String?

    private let service = WeatherService()

    func fetch(lat: Double, lon: Double) async {
        do {
            async let r = service.fetch(lat: lat, lon: lon)
            async let place = reverseGeocode(lat: lat, lon: lon)
            let (resp, pname) = try await (r, place)

            temperature = resp.current.temperature_2m
            humidity    = resp.current.relative_humidity_2m
            windSpeed   = resp.current.wind_speed_10m
            placeName   = pname
            errorMessage = nil
        } catch {
            temperature = nil
            humidity    = nil
            windSpeed   = nil
            placeName   = nil
            errorMessage = "No se pudo obtener el clima: \(error.localizedDescription)"
        }
    }

    private func reverseGeocode(lat: Double, lon: Double) async throws -> String? {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(.init(latitude: lat, longitude: lon))
        let p = placemarks.first
        return [p?.locality, p?.administrativeArea, p?.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
