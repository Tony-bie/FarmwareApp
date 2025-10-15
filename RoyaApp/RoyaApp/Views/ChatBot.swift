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

    var body: some View {
        NavigationStack {
            VStack {
                // ScrollView para mensajes
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
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
        }
    }

    private func sendMessage() {
        // Agregamos el mensaje del usuario a la UI
        let userMessage = "Tú: \(prompt)"
        viewModel.messages.append(userMessage)
        let messageToSend = prompt
        prompt = ""

        Task {
            viewModel.isResponding = true
            // Enviamos solo el mensaje limpio al modelo
            let aiResponse = await viewModel.processMessage(messageToSend)
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
    ChatView()
}


