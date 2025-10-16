//
//  DetalleLote_ClimaMapa.swift
//  Detalles
//

import SwiftUI
import CoreLocation
import MapKit

// MARK: - Colors
extension Color {
    static let appBg   = Color(red: 0.89, green: 0.93, blue: 0.88)
    static let cardFill = Color.white.opacity(0.65)
    static let stroke  = Color.black.opacity(0.06)
    static let accent  = Color(red: 0.25, green: 0.45, blue: 0.30)
}

// MARK: - Identifiable para anotaciones (iOS 16)
private struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Location Manager (ubicación actual)
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first { location = first }
    }
}

// MARK: - OpenWeatherMap modelos
struct OWMWeatherResponse: Decodable {
    let weather: [OWMWeather]
    let main: OWMMain
    let wind: OWMWind
    let name: String?
}
struct OWMWeather: Decodable { let main: String; let description: String; let icon: String }
struct OWMMain: Decodable { let temp: Double; let humidity: Double; let temp_min: Double?; let temp_max: Double? }
struct OWMWind: Decodable { let speed: Double } // m/s

// MARK: - API Client
enum WeatherAPIError: Error, LocalizedError {
    case missingAPIKey, badURL, badResponse, decodingFailed
    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Falta la API key de OpenWeatherMap (OPENWEATHER_API_KEY en Info.plist)."
        case .badURL: return "No se pudo construir la URL de clima."
        case .badResponse: return "Respuesta no válida del servidor."
        case .decodingFailed: return "No se pudo decodificar la respuesta de clima."
        }
    }
}

struct OpenWeatherAPI {
    static func apiKey() -> String? {
        (Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String)
            .flatMap { $0.isEmpty ? nil : $0 }
    }

    static func currentWeather(lat: Double, lon: Double, lang: String = "es", units: String = "metric") async throws -> OWMWeatherResponse {
        guard let key = apiKey() else { throw WeatherAPIError.missingAPIKey }
        var comps = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        comps?.queryItems = [
            .init(name: "lat", value: String(lat)),
            .init(name: "lon", value: String(lon)),
            .init(name: "appid", value: key),
            .init(name: "units", value: units), // metric = °C
            .init(name: "lang", value: lang)    // es = español
        ]
        guard let url = comps?.url else { throw WeatherAPIError.badURL }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw WeatherAPIError.badResponse
        }
        do { return try JSONDecoder().decode(OWMWeatherResponse.self, from: data) }
        catch { throw WeatherAPIError.decodingFailed }
    }
}

// MARK: - ViewModel (clima + reverse geocode)
@MainActor
final class WeatherVM: ObservableObject {
    @Published var data: OWMWeatherResponse?
    @Published var errorMessage: String?
    @Published var placeName: String?

    func fetch(lat: Double, lon: Double) async {
        do {
            async let w = OpenWeatherAPI.currentWeather(lat: lat, lon: lon)
            async let p = reverseGeocode(lat: lat, lon: lon)
            let (weather, place) = try await (w, p)
            self.data = weather
            self.placeName = place
            self.errorMessage = nil
        } catch {
            self.data = nil
            self.placeName = nil
            self.errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "No se pudo obtener el clima: \(error.localizedDescription)"
        }
    }

    private func reverseGeocode(lat: Double, lon: Double) async throws -> String? {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(.init(latitude: lat, longitude: lon))
        let p = placemarks.first
        return [p?.locality, p?.administrativeArea, p?.country].compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - Vista principal (mapa + clima)
struct DetalleLote: View {
    @StateObject private var vm = WeatherVM()
    @StateObject private var locationManager = LocationManager()

    // Fallback si no hay permiso/ubicación aún (CDMX)
    private let defaultLocation = CLLocation(latitude: 19.4326, longitude: -99.1332)
    private var effectiveLocation: CLLocation { locationManager.location ?? defaultLocation }

    // Estado del mapa (iOS16 + iOS17)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    // Pins actuales para iOS 16
    private var currentPins: [MapPin] {
        [MapPin(coordinate: effectiveLocation.coordinate)]
    }

    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()

                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Detalles del Lote").font(.title2.bold())
                        Text(vm.placeName ?? "Ubicación actual")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    // Mapa con pin
                    mapSection
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .frame(height: 200)

                    // Tarjeta de clima
                    Group {
                        if isPreview {
                            weatherCardMock
                        } else if let d = vm.data {
                            weatherCard(data: d)
                        } else if let err = vm.errorMessage {
                            Text(err).foregroundColor(.red)
                        } else {
                            ProgressView("Cargando clima…")
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ConfigView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.accent)
                    }
                }
            }
        }
        // Al cargar / cambiar ubicación: centramos mapa y pedimos clima
        .task(id: effectiveLocationKey) {
            let c = effectiveLocation.coordinate
            recenterMap(to: c)
            if !isPreview {
                await vm.fetch(lat: c.latitude, lon: c.longitude)
            }
        }
        .onChange(of: locationManager.location) { _, newLoc in
            guard let loc = newLoc else { return }
            recenterMap(to: loc.coordinate)
            Task { await vm.fetch(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude) }
        }
    }

    private var effectiveLocationKey: String {
        let c = effectiveLocation.coordinate
        return "\(c.latitude)-\(c.longitude)"
    }

    private func recenterMap(to c: CLLocationCoordinate2D) {
        region.center = c
        camera = .region(MKCoordinateRegion(center: c,
                                            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)))
    }

    // MARK: - Map (iOS 17 / iOS 16) — sin declaraciones internas
    @ViewBuilder
    private var mapSection: some View {
        if #available(iOS 17.0, *) {
            Map(position: $camera, interactionModes: []) {
                Marker("Aquí estás", coordinate: effectiveLocation.coordinate)
            }
            .allowsHitTesting(false)
        } else {
            Map(coordinateRegion: $region,
                interactionModes: [],
                showsUserLocation: false,
                annotationItems: currentPins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.red)
                        .shadow(radius: 2)
                }
            }
            .allowsHitTesting(false)
        }
    }

    // MARK: - UI clima
    @ViewBuilder
    private func weatherCard(data: OWMWeatherResponse) -> some View {
        let temp = Int(round(data.main.temp))
        let desc = data.weather.first?.description.capitalized ?? "—"
        let windKMH = Int(round(data.wind.speed * 3.6))
        let humidity = Int(round(data.main.humidity))
        let icon = data.weather.first?.icon ?? "01d"

        VStack(spacing: 8) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { img in
                    img.resizable().scaledToFit()
                } placeholder: { ProgressView().scaleEffect(0.8) }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(temp)°C").font(.system(size: 36, weight: .bold))
                    Text(desc).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 16) {
                Label("Viento: \(windKMH) km/h", systemImage: "wind")
                Label("Humedad: \(humidity)%", systemImage: "humidity")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weatherCardMock: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill").font(.system(size: 44))
                VStack(alignment: .leading, spacing: 2) {
                    Text("22°C").font(.system(size: 36, weight: .bold))
                    Text("Parcialmente nublado").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 16) {
                Label("Viento: 10 km/h", systemImage: "wind")
                Label("Humedad: 65%", systemImage: "humidity")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Config dummy
struct ConfigGoView: View {
    var body: some View {
        Text("Configuración").navigationTitle("Settings")
    }
}

// MARK: - Preview
#Preview { DetalleLote() }
