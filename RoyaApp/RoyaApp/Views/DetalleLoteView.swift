//  Created by Paloma Belenguer
import SwiftUI
import CoreLocation
import MapKit

struct DetalleLote: View {
    @StateObject private var vm = WeatherModel()
    @StateObject private var locationManager = LocationManager()

    // Ubicación por defecto (Monterrey)
    private let defaultLocation = CLLocation(latitude: 25.6866, longitude: -100.3161)
    private var effectiveLocation: CLLocation { locationManager.location ?? defaultLocation }

    // Solo usamos cámara (iOS 17+)
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    private var effectiveLocationKey: String {
        let c = effectiveLocation.coordinate
        return "\(c.latitude)-\(c.longitude)"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 16) {
                    // Título + lugar
                    VStack(spacing: 4) {
                        Text("Detalles del Lote").font(.title2.bold())
                        if let place = vm.placeName {
                            Text(place).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 8)

                    // Mapa (iOS 17+)
                    Map(position: $camera, interactionModes: []) {
                        Marker("Aquí estás", coordinate: effectiveLocation.coordinate)
                    }
                    .allowsHitTesting(false)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .frame(height: 200)

                    // Tarjeta de clima
                    Group {
                        if let t = vm.temperature {
                            weatherCard(
                                temperatureC: t,
                                humidityPct: vm.humidity,
                                windSpeedMs: vm.windSpeed
                            )
                        } else if let msg = vm.errorMessage {
                            Text(msg)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            weatherCardLoading
                        }

                        NavigationLink {
                            ConfigView().toolbar(.hidden, for: .tabBar)
                        } label: {
                            Text("Configuración")
                        }

                        NavigationLink {
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                                .toolbar(.hidden, for: .tabBar)
                        } label: {
                            Text("Cerrar sesión")
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: effectiveLocationKey) {
                let c = effectiveLocation.coordinate
                await vm.fetch(lat: c.latitude, lon: c.longitude)
                recenterMap(to: c)
            }
        }
    }

    // MARK: - Helpers
    private func recenterMap(to c: CLLocationCoordinate2D) {
        camera = .region(MKCoordinateRegion(
            center: c,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
    }

    // MARK: - UI clima
    @ViewBuilder
    private func weatherCard(
        temperatureC: Double,
        humidityPct: Double?,
        windSpeedMs: Double?
    ) -> some View {
        let temp     = Int(round(temperatureC))
        let humidity = humidityPct.map { Int(round($0)) }
        let windKMH  = windSpeedMs.map { Int(round($0 * 3.6)) }

        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 44))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(temp)°C").font(.system(size: 36, weight: .bold))
                    if let h = humidity {
                        Text("Humedad \(h)%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            HStack(spacing: 16) {
                if let k = windKMH {
                    Label("Viento: \(k) km/h", systemImage: "wind")
                }
                if let h = humidity {
                    Label("Humedad: \(h)%", systemImage: "humidity")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weatherCardLoading: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ProgressView().scaleEffect(1.0)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cargando…").font(.headline)
                    Text("Obteniendo clima actual").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview
#Preview { DetalleLote() }
