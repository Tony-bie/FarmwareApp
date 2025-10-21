import SwiftUI
import CoreLocation
import MapKit

// Wrapper Identifiable para anotaciones en iOS 16
private struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct DetalleLote: View {
    @StateObject private var vm = WeatherModel()
    @StateObject private var locationManager = LocationManager()

   
    private let defaultLocation = CLLocation(latitude: 25.6866, longitude: -100.3161)
    private var effectiveLocation: CLLocation { locationManager.location ?? defaultLocation }

    // Estado del mapa (iOS 16 + iOS 17)
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

                    // Mapa con pin
                    mapSection
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .frame(height: 200)

                    // Tarjeta de clima (usa propiedades de WeatherModel)
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
                        NavigationLink{
                            ConfigView()
                                .toolbar(.hidden, for: .tabBar)
                        } label: {
                            Text("Configuración")
                        }
                        NavigationLink{
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
            // Traer clima y recentrar cuando cambie la ubicación (o al entrar)
            .task(id: effectiveLocationKey) {
                let c = effectiveLocation.coordinate
                await vm.fetch(lat: c.latitude, lon: c.longitude)
                recenterMap(to: c)
            }
        }
    }

    // MARK: - Helpers
    private func recenterMap(to c: CLLocationCoordinate2D) {
        region.center = c
        camera = .region(MKCoordinateRegion(
            center: c,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
    }

    // MARK: - Map (iOS 17 / iOS 16)
    @ViewBuilder
    private var mapSection: some View {
        if #available(iOS 17.0, *) {
            Map(position: $camera, interactionModes: []) {
                Marker("Aquí estás", coordinate: effectiveLocation.coordinate)
            }
            .allowsHitTesting(false)
        } else {
            Map(
                coordinateRegion: $region,
                interactionModes: [],
                showsUserLocation: false,
                annotationItems: [MapPin(coordinate: effectiveLocation.coordinate)]
            ) { pin in
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

    // MARK: - UI clima (desde valores del VM)
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
