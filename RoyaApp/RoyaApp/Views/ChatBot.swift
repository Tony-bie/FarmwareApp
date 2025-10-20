//
//  ChatBot.swift
//  RoyaApp
//
//  Created by David Ortega Muzquiz on 15/10/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var prompt: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                // ScrollView para mensajes
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            if viewModel.messages.isEmpty {
                                welcomeMessage
                            }
                            
                            ForEach(viewModel.messages, id: \.self) { msg in
                                MessageRow(message: msg)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input y botón de enviar
                HStack(spacing: 8) {
                    TextField("Escribe tu mensaje...", text: $prompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(4)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .padding(8)
                            .background(Color.indigo.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(prompt.isEmpty || viewModel.isResponding)
                }
                .padding()
            }
            .navigationTitle("Chat AI")
            .background(Color(.secondarySystemBackground))
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "atom")
                .font(.system(size: 60))
                .foregroundColor(.indigo.opacity(0.7))
            
            Text("Chat con IA")
                .font(.title2.bold())
            
            Text("Pregunta cualquier cosa sobre plantaciones de café, la roya y cómo cuidar tus cultivos.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func sendMessage() {
        guard !prompt.isEmpty else { return }
        
        let userMessage = "Tú: \(prompt)"
        viewModel.messages.append(userMessage)
        let messageToSend = prompt
        prompt = ""

        Task {
            viewModel.isResponding = true
            let aiResponse = await viewModel.processMessage(messageToSend)
            
            // Verificar si hubo error
            if aiResponse.starts(with: "Perdón") || aiResponse.starts(with: "Error") {
                errorMessage = "Hubo un problema al conectar con el servicio de IA. Por favor, verifica que Apple Intelligence esté habilitado en Ajustes del sistema."
                showError = true
            }
            
            viewModel.messages.append("AI: \(aiResponse)")
            viewModel.isResponding = false
        }
    }
}

@available(iOS 26.0, *)
struct MessageRow: View {
    let message: String

    var body: some View {
        Text(message)
            .padding(8)
            .background(message.starts(with: "Tú:") ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: message.starts(with: "Tú:") ? .trailing : .leading)
            .id(message)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ChatView()
    } else {
        Text("Requiere iOS 26.0+")
    }
}
