//
//  HistorialView.swift
//  RoyaApp
//
//  Created by Alumno on 11/09/25.
//


import SwiftUI

struct HIstorialView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Historial y compartir")
                    .font(.title2)
                    .bold()
                    .frame(width: 300, height: 400)
                
                Spacer()
                
                Image(systemName: "calendar")
                    .frame(width: 100, height: 100)
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    HIstorialView()
}
