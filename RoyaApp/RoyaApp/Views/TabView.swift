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
            HistoryView()
                .tabItem {
                    Label("Historial", systemImage: "list.bullet")
                }
            EducationalView()
                .tabItem {
                    Label("Educación", systemImage: "book")
                }
            DetalleLote()
                .tabItem {
                    Label("Detalle", systemImage: "pencil")
                }
        }
    }
}
   
