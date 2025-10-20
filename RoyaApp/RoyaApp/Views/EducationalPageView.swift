//
//  RoyalFile.swift
//  RoyaIA
//
//  Created by Paloma Belenguer on 10/9/25.
//

import SwiftUI
import UIKit

struct EducationalView: View {
    @State private var AIChat: Bool = false
    @State private var showUnavailableAlert: Bool = false
    @StateObject private var aiChecker = AppleIntelligenceChecker()
    
    private let bg = Color(red: 0.93, green: 0.96, blue: 0.91)

    private let pQueEs1 =
    "La roya del café (Hemileia vastatrix) es una enfermedad fúngica que afecta principalmente las plantas de café y es una de las más destructivas para la producción cafetera mundial. El hongo se desarrolla en las hojas del cafeto formando pequeñas manchas amarillas que, con el tiempo, se convierten en áreas necrosadas."
    private let pQueEs2 =
    "A medida que la infección avanza, las hojas se caen prematuramente, debilitando la planta y reduciendo su capacidad de fotosíntesis. Esto puede llevar a una disminución en la producción de café, afectando tanto la calidad como la cantidad de la cosecha."
    private let pTransmision =
    "La roya se transmite principalmente por esporas dispersadas por el viento, el agua de lluvia o el contacto directo entre plantas infectadas. El hongo prospera en condiciones de alta humedad y temperaturas moderadas, y es más prevalente cuando hay baja rotación de cultivos o no se aplican medidas de control."

    private let prevencion: [(titulo: String, desc: String)] = [
        ("Monitoreo constante","Revisar hojas con frecuencia para detectar manchas amarillas o pardeadas y actuar de inmediato."),
        ("Poda y manejo de sombra","Mejorar la ventilación y reducir la humedad; cultivar bajo sombra ayuda a regular el microclima."),
        ("Uso de variedades resistentes","Invertir en materiales genéticos con resistencia para disminuir el riesgo de infección a largo plazo."),
        ("Uso controlado de fungicidas","Aplicar productos específicos solo cuando corresponda y siguiendo las recomendaciones de seguridad."),
        ("Agroforestería","Integrar árboles nativos para aumentar biodiversidad, reducir la erosión y fortalecer la resiliencia del cafetal.")
    ]

    private let notasFinales: [String] = [
        "Los máximos de incidencia y severidad de la enfermedad coinciden con los picos de cosecha.",
        "Y la disminución en la producción de grano está directamente relacionada con el porcentaje de defoliación de las plantas.",
        "Pero lo más grave, es que el efecto de la defoliación es acumulativo.",
        "Es decir que, la defoliación ocurrida en un año, tendrá efectos en la disminución de la producción de café en el año siguiente.",
        "De aquí la importancia de detectar la presencia de la enfermedad a tiempo y realizar los controles preventivos de manera oportuna."
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Roya del Café")
                                .font(.system(size: 34, weight: .bold))
                            Text("Qué es, transmisión y prevención")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)

                        SectionCard(title: "¿Qué es la Roya del Café?") {
                            Text(pQueEs1)
                            Text(pQueEs2)
                        }

                        SectionCard(title: "Transmisión y condiciones que la favorecen") {
                            Text(pTransmision)
                        }

                        SectionCard(title: "Cuidado y Prevención de la Roya del Café") {
                            VStack(spacing: 16) {
                                ForEach(Array(prevencion.enumerated()), id: \.offset) { idx, item in
                                    NumberedRow(number: idx + 1, title: item.titulo, desc: item.desc)
                                }
                            }
                        }

                        Text("Combinando estas prácticas se puede controlar la roya, proteger los cultivos y sostener una producción sostenible y rentable en el tiempo.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)

                        SectionCard(title: "") {
                            escalaImage
                        }

                        SectionCard(title: "") {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(notasFinales, id: \.self) { linea in
                                    Text(linea)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }

                HStack {
                    Spacer()
                    VStack { Image(systemName: "camera.viewfinder"); Text("Escanear").font(.caption) }
                        .foregroundColor(.green)
                    Spacer()
                    VStack { Image(systemName: "clock"); Text("Historial").font(.caption) }
                    Spacer()
                    VStack { Image(systemName: "person.fill"); Text("Cuenta").font(.caption) }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 5)
                
                // Navegación condicional a ChatView
                if #available(iOS 26.0, *) {
                    NavigationLink(destination: ChatView(), isActive: $AIChat) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .background(bg.ignoresSafeArea())
            .navigationTitle("Roya del Café")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        handleAIChatTap()
                    }) {
                        VStack {
                            Image(systemName: "atom")
                            Text("Pregúntale a IA")
                                .font(.caption2)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.vertical, 6)
                        .frame(minHeight: 44)
                    }
                }
            }
            .alert("Función no disponible", isPresented: $showUnavailableAlert) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(aiChecker.unavailableMessage)
            }
            .fullScreenCover(isPresented: $AIChat) {
                if #available(iOS 26.0, *), aiChecker.isAvailable {
                    ChatView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleAIChatTap() {
        if #available(iOS 26.0, *) {
            if aiChecker.isAvailable {
                AIChat = true
            } else {
                showUnavailableAlert = true
            }
        } else {
            showUnavailableAlert = true
        }
    }

    private var escalaImage: some View {
        Group {
            if let ui = UIImage(named: "EscalaRoya") {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.6))
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.green.opacity(0.7))
                        Text("Añade la imagen a Assets como \"EscalaRoya\"")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .frame(height: 220)
            }
        }
        .cornerRadius(12)
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    init(title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !title.isEmpty {
                Text(title).font(.title2.weight(.semibold))
            }
            VStack(alignment: .leading, spacing: 10) { content }
                .font(.body)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .background(Color.white.opacity(0.7))
        .cornerRadius(12)
    }
}

private struct NumberedRow: View {
    let number: Int
    let title: String
    let desc: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Color.green.opacity(0.18)).frame(width: 28, height: 28)
                Text("\(number)").font(.footnote.weight(.bold)).foregroundStyle(.green)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text(desc).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    EducationalView()
}
