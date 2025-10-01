//
//  Detailview.swift
//  Detalles
//
//  Created by Alumno on 10/09/25.
//

import SwiftUI
import MapKit

extension Color{
    static let appBg = Color(red: 0.89, green: 0.93, blue: 0.88)
    static let cardFill = Color.white.opacity(0.65)
    static let stroke = Color.black.opacity(0.06)
    static let accent = Color(red: 0.25, green: 0.45, blue: 0.30)
}

struct format_map<Content: View>: View{
    let content: Content
    init (@ViewBuilder content: () -> Content) {self.content = content()}
        var body: some View {
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.16), radius: 12, x: 0, y: 6)
        }
}



struct DetalleLote: View{
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    var body: some View{
        ZStack{
            Color.appBg.ignoresSafeArea()
            VStack(spacing: 16){
                Text("Detalles del lote")
                    .font(.title2.bold())
                    .padding(.top,8)
                format_map{
                    ZStack{
                        Map(coordinateRegion: $region)
                            .disabled(true)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .frame(height: 160)
                        Image(systemName: "mappin.circle.fill")
                    }
                }
                format_map{
                    VStack(alignment: .leading, spacing: 10){
                        HStack(spacing: 10){
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            Text("Sin signos de enfermedad")
                                .font(.headline)
                        }
                        HStack(alignment: .top, spacing: 10){
                            Image(systemName: "bell.badge")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                            Text("El técnico recibió correctamente la información y se pondrá en contacto")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                format_map{
                    HStack(alignment: .top, spacing: 16){
                        VStack(alignment: .leading, spacing: 8){
                            Text("Notas:")
                                .font(.headline)
                            Text("Tener cuidado con la cantidad de agua")
                            Text("Revisar el estado de las hojas constantemente")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading, spacing: 10){
                            Text("Antes")
                                .font(.headline)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                            Text("Después")
                                .font(.headline)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                        }
                        .frame(width: 140, alignment: .leading)
                    }
                }
                format_map{
                    Text("Los datos se sincronizan automaticamente la proxima vez que esté en linea")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    Spacer()
                    VStack {
                        Image(systemName: "camera.viewfinder")
                        Text("Escanear")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                    Spacer()
                    VStack {
                        Image(systemName: "clock")
                        Text("Historial")
                            .font(.caption)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Cuenta")
                            .font(.caption)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                )
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
        }
    }
}



struct DetalleLote_Previews: PreviewProvider {
    static var previews: some View {
        DetalleLote()
    }
}

