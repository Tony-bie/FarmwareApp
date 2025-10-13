//
//  ResultadosView.swift
//  RoyaIA
//
//  Created by Santiago Cordova on 10/09/25.
//

import SwiftUI
import CoreML
import Vision



struct ResultadosView: View {
    var image: UIImage?
    @State private var resultado: String = ""
    @State private var descripcion: String = ""
    
    
    
    var body: some View {
        ZStack {
            Color(red: 0.89, green: 0.93, blue: 0.88)
                .ignoresSafeArea()
            VStack {
                
                Text("Resultados del análisis")
                    .font(.title)
                    .bold()
                    .padding()
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .onAppear {
                            analizarImagen(image)
                        }
                } else {
                    Text("No se encontró imagen")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 10) {
                    Text(resultado)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                                    
                    if !descripcion.isEmpty {
                        Text(descripcion)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 80)
            }
            .navigationTitle("Resultados")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    private func analizarImagen(_ image: UIImage) {
            guard let ciImage = CIImage(image: image) else {
                resultado = "Error al procesar la imagen"
                return
            }
            
            // Cargar el modelo generado por Core ML
            guard let model = try? VNCoreMLModel(for: RoyaClassifier_1().model) else {
                resultado = "No se pudo cargar el modelo"
                return
            }
            
            let request = VNCoreMLRequest(model: model) { request, error in
                if let results = request.results as? [VNClassificationObservation],
                   let top = results.first {
                    DispatchQueue.main.async {
                        let label = top.identifier
                        let confidence = Int(top.confidence * 100)
                        resultado = "Predicción: \(label) (\(confidence)%)"
                        descripcion = descripcionParaClase(label)
                    }
                } else {
                    resultado = "No se obtuvieron resultados del modelo"
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    DispatchQueue.main.async {
                        resultado = "Error en la inferencia: \(error.localizedDescription)"
                    }
                }
            }
        }
    
    private func descripcionParaClase(_ label: String) -> String {
            switch label {
            case "sano":
                return "El cultivo se encuentra saludable, sin señales de roya."
            case "1-5":
                return "Infección leve detectada. Se recomienda monitorear el cultivo."
            case "6-20":
                return "Infección moderada. Podría requerir aplicación de tratamiento."
            case "21-50":
                return "Infección severa. Es importante aplicar control inmediato."
            case "+50":
                return "Infección muy alta. Se recomienda tratamiento urgente."
            case "otros":
                return "La imagen no corresponde claramente a una hoja de cultivo afectada."
            default:
                return ""
            }
        }
}

#Preview {
    ResultadosView(image: UIImage(systemName: "leaf"))
}
