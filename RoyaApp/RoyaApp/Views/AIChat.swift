//
//  AIChat.swift
//  RoyaApp
//
//  Created by Alumno on 30/09/25.
//

import SwiftUI
import FoundationModels

struct AIChat: View {
    @State private var response = ""
    @State private var prompt: String = "Pregunta sobre la Roya"
    
    var body: some View {
        NavigationStack {
            List {
                Section{
                    Text(response)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        // .glassEffect(in: .rect(cornerRadius: 20))
                } header: {
                    Text("Response")
                }
                
                Section{
                    VStack{
                        TextEditor(text: $prompt)
                            .font(.caption)
                            .padding()
                            .foregroundStyle(.secondary)
                        // .glassEffect(in: .rect(cornerRadius: 20))
                        
                        HStack {
                            Spacer()
                            Button{
                                let session = LanguageModelSession()
                                
                                Task{
                                    response = try! await session.respond(to: Prompt(prompt)).content
                                }
                            } label: {
                                HStack{
                                    Image(systemName: "paperplane.fill")
                                    Text("Send")
                                }
                            }
                            .padding(.top, 8)
                            .tint(.indigo)
                            .disabled(prompt.isEmpty)
                            
                        }
                    }
                }header: {
                    Text("Prompt")
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Simple AI Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AIChat()
        
}
