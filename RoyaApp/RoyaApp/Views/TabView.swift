//
//  TebView.swift
//  RoyaIA
//
//  Created by Alumno on 10/09/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .escanear
    
    enum Tab {
        case escanear, historial, perfil, datos
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Vistas principales
            Group {
                switch selectedTab {
                case .escanear:
                    EscanearView()
                case .historial:
                    HistoryView()
                case .perfil:
                    RoyalFile()
                case .datos:
                    DetalleLote()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Barra inferior personalizada
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .shadow(radius: 5)
                .overlay(
                    HStack {
                        // Botón Escanear
                        Button(action: {
                            selectedTab = .escanear
                        }) {
                            VStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 24))
                                Text("Escanear")
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == .escanear ? .green : .gray)
                        }
                        Spacer()
                        
                        // Botón Historial
                        Button(action: {
                            selectedTab = .historial
                        }) {
                            VStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 24))
                                Text("Historial")
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == .historial ? .green : .gray)
                        }
                        Spacer()
                        
                        // Botón Perfil
                        Button(action: {
                            selectedTab = .perfil
                        }) {
                            VStack {
                                Image(systemName: "person")
                                    .font(.system(size: 24))
                                Text("Perfil")
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == .perfil ? .green : .gray)
                        }
                        Spacer()
                        
                        Button(action: { selectedTab = .datos }) {
                            VStack {
                                Image(systemName: "chart.bar") // icono cualquiera
                                    .font(.system(size: 24))
                                Text("Datos")
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == .datos ? .green : .gray)
                            
                        }
                    }
                    .padding(.horizontal, 40)
                )
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

