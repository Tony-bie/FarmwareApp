//
//  TebView.swift
//  RoyaIA
//
//  Created by Alumno on 10/09/25.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        TabView {
            EscanearView()
                .tabItem {
                    Label("Escanear", systemImage: "qrcode.viewfinder")
                }
            HIstorialView()
                .tabItem {
                    Label("Historias", systemImage: "list.bullet")
                }
            EducationalPage()
                .tabItem {
                    Label("Educación", systemImage: "lightbulb")
                }
            DetalleLote()
                .tabItem {
                    Label("Detalle", systemImage: "pencil")
                }
        }
    }
}
