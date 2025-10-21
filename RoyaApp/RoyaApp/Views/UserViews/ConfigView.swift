//
//  ConfigView.swift
//  RoyaApp
//
//  Created by Enrique Antonio Pires Rodríguez on 07/10/25.
//

import Foundation
import SwiftUI

struct ConfigView: View {
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var username  = ""
    @State private var phonenumber = ""
    @State private var email      = ""
    @State private var password  = ""
    @State private var newpassword  = ""
    @State private var confirmpassword  = ""
    
    @StateObject private var configModel = ConfigModel()
    @State private var showDeleteAlert = false
    @State private var deletePassword = ""
    
    @State private var goToLogin = false

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Configuración de cuenta")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal, 15)
                        
                       
                        LabelField(systemName: "person.fill", title: "First name") {
                            TextField("First name", text: $firstName)
                                .textInputAutocapitalization(.words)
                        }
                        .padding(.horizontal, 15)
                        
                        LabelField(systemName: "person", title: "Last name") {
                            TextField("Last name", text: $lastName)
                                .textInputAutocapitalization(.words)
                        }
                        .padding(.horizontal, 15)
                        
                        LabelField(systemName: "person.crop.circle", title: "Username") {
                            TextField("Username", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        .padding(.horizontal, 15)
                        
                        LabelField(systemName: "envelope.fill", title: "Email") {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        .padding(.horizontal, 15)
                        LabelField(systemName: "phone.fill", title: "Phone") {
                            TextField("Phone", text: $phonenumber)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        .padding(.horizontal, 15)
                        
                        LabelField(systemName: "lock.fill", title: "Old Password") {
                            SecureField("••••••••", text: $password)
                                .textContentType(.password)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 15)
                        
                        LabelField(systemName: "lock.fill", title: "Password") {
                            SecureField("••••••••", text: $newpassword)
                                .textContentType(.newPassword)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 15)
                        
                        LabelField(systemName: "lock.rotation", title: "Repeat password") {
                            SecureField("•••••••••••••", text: $confirmpassword)
                                .textContentType(.newPassword)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 15)
                        
    
                        Button("Guardar cambios") {
                            Task {
                                guard let id = AppSession.shared.userId else { return }
                                let update = UpdateData(
                                    first_name: firstName.isEmpty ? nil : firstName,
                                    last_name:  lastName.isEmpty  ? nil : lastName,
                                    username:   username.isEmpty  ? nil : username,
                                    email:      email.isEmpty     ? nil : email.lowercased(),
                                    phonenumber: phonenumber.isEmpty ? nil : phonenumber,
                                    current_password: password.isEmpty ? nil : password,
                                    new_password:     newpassword.isEmpty ? nil : newpassword,
                                    confirm_password: confirmpassword.isEmpty ? nil : confirmpassword
                                )
                                await configModel.saveChanges(userId: id, data: update)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 4)
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Text("Eliminar cuenta")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 4)
                        .alert("Eliminar cuenta", isPresented: $showDeleteAlert) {
                            SecureField("Contraseña actual", text: $deletePassword)
                            Button("Cancelar", role: .cancel) {}
                            Button("Eliminar", role: .destructive) {
                                Task {
                                    let delete = DeleteIn(current_password: deletePassword)
                                    guard let id = AppSession.shared.userId else { return }
                                    await configModel.deleteAccount(userId: id, delete: delete)
                                    deletePassword = ""
                    
                                }
                            }
                        } message: {
                            Text("Esta acción es irreversible. ¿Deseas continuar?")
                        }
                        
                        Spacer(minLength: 8)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Cuenta")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: configModel.isDeleted) { deleted in
            if deleted {
                AppSession.shared.logout()
                goToLogin = true
            }
        }
        .fullScreenCover(isPresented: $goToLogin) {
            LoginView()
                .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    ConfigView()
}
