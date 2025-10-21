//
//  HistorialView.swift
//  RoyaIA
//
//  Created by Alumno on 04/09/25.
//


import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showCalendar = false
    @State private var selectedDate: Date? = nil
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    var filteredHistorial: [Historial] {
        guard let selected = selectedDate else { return viewModel.arrHistorial }
        return viewModel.arrHistorial.filter { historial in
            guard let date = dateFormatter.date(from: historial.date) else { return false }
            return Calendar.current.isDate(date, inSameDayAs: selected)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        ForEach(filteredHistorial) { historial in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(historial.date)
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(historial.images, id: \.self) { urlString in
                                            NavigationLink(destination: AnalysisView(imageURL: urlString)) {
                                                AsyncImage(url: URL(string: urlString)) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                            .frame(width: 110, height: 90)
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 110, height: 90)
                                                            .clipped()
                                                            .cornerRadius(8)
                                                    case .failure:
                                                        Image(systemName: "photo")
                                                            .frame(width: 110, height: 90)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
                
               
            }
            .navigationTitle("Historial & Compartir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCalendar.toggle()
                    }) {
                        Image(systemName: "calendar")
                    }
                }
            }
            .sheet(isPresented: $showCalendar) {
                VStack {
                    DatePicker(
                        "Selecciona una fecha",
                        selection: Binding(
                            get: { selectedDate ?? Date() },
                            set: { selectedDate = $0 }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    
                    HStack {
                        Button("Cerrar") {
                            showCalendar = false
                        }
                        .padding()
                        
                        Button("Mostrar todas") {
                            selectedDate = nil
                            showCalendar = false
                        }
                        .padding()
                    }
                }
            }
            .background(Color(red: 0.93, green: 0.96, blue: 0.91).ignoresSafeArea())
        }
    }
}

struct AnalysisView: View {
    let imageURL: String
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxHeight: 300)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                case .failure:
                    Image(systemName: "photo")
                        .frame(maxHeight: 300)
                @unknown default:
                    EmptyView()
                }
            }
            
            Text("Aquí va el análisis de la imagen...")
                .padding()
            
            Spacer()
        }
        .navigationTitle("Análisis")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

