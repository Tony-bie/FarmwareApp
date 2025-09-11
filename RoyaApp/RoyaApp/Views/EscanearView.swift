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
                    .onChange(of: camera.capturedImage) { newImage in
                        if newImage != nil {
                            navigateToResults = true
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
                    
                    // Navegación segura
                    NavigationLink(
                        isActive: $navigateToResults,
                        destination: {
                            Group {
                                if let image = camera.capturedImage {
                                    ResultadosView(image: image)
                                } else {
                                    EmptyView()
                                }
                            }
                        },
                        label: {
                            EmptyView()
                        }
                    )
                    
                    .onAppear {
                        camera.capturedImage = nil
                        navigateToResults = false
                    }
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
            }
        }
    }
    
    
    // Preview correcto
    struct EscanearView_Previews: PreviewProvider {
        static var previews: some View {
            EscanearView()
        }
    }


