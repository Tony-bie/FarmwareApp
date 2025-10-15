//
//  EscanearView.swift
//  RoyaIA
//
//  Created by Santiago Cordova on 10/09/25.
//
import SwiftUI
import UIKit


struct EscanearView: View {
    @StateObject private var camera = CamaraManager()
    @State private var showImagePicker = false
    @State private var navigateToResults = false
    // Etapa por defecto; ajusta según tu flujo (por ejemplo: "siembra", "floración", etc.)
    @State private var etapa: String = "cosecha"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.89, green: 0.93, blue: 0.88)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Escanear Cosecha")
                        .font(.title)
                        .bold()
                        .padding()
                    
                    ZStack {
                        CamaraPreview(session: camera.getSession())
                            .cornerRadius(10)
                        
                        if let image = camera.capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                        }
                    }
                    .frame(width: 300, height: 400)
                    .onChange(of: camera.capturedImage) { _, newImage in
                        if let image = newImage {
                            Task {
                                do {
                                    let url = try await ImageUploader.uploadImage(image, etapa: etapa)
                                    print("✅ Imagen subida con URL:", url)
                                    // Aquí puedes pasar esa URL a ResultadosView si quieres
                                    // o guardarla en Supabase (tabla 'photos')
                                    
                                    navigateToResults = true
                                } catch {
                                    print("❌ Error subiendo imagen:", error)
                                }
                            }
                        }
                    }
                    
                    Text("Por favor asegurate que los cultivos están enfocados y bien iluminados")
                        .font(.footnote)
                        .padding()
                    
                    HStack {
                        Button {
                            camera.takePhoto()
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)
                                .overlay(Circle().stroke(Color.black, lineWidth: 3))
                        }
                        
                        Spacer().frame(width: 40)
                        
                        Button {
                            showImagePicker = true
                        } label: {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .frame(width: 50, height: 40)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    camera.capturedImage = nil
                    navigateToResults = false
                }
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    if camera.capturedImage != nil {
                        navigateToResults = true
                    }
                }) {
                    ImagePicker(selectedImage: $camera.capturedImage,
                                sourceType: .photoLibrary)
                }
            }
            .navigationDestination(isPresented: $navigateToResults) {
                Group {
                    if let image = camera.capturedImage {
                        ResultadosView(image: image /* , url: uploadedURL */)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}


// Preview correcto
struct EscanearView_Previews: PreviewProvider {
    static var previews: some View {
        EscanearView()
    }
}
