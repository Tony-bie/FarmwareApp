//
//  LoginView.swift
//  RoyaApp
//
//  Created by Alumno on 30/09/25.
//

import SwiftUI

struct LoginView : View {
    @State private var identifier = ""
    @State private var password  = ""
    @State private var showPass  = false
    @StateObject private var loginVM = LoginModel()
    @State private var showSuccess = false
    @State private var showError = false

    
    private var isPhone: Bool {
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count == 10 && trimmed.allSatisfy(\.isNumber)
    }
    private var isEmail: Bool {
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    var body: some View {
        NavigationStack{
            ZStack{
                Color.appBg.ignoresSafeArea()
                VStack(alignment: .leading){
                    NavigationLink(isActive: $loginVM.isLoggedIn) {
                        MainView()
                            .navigationBarBackButtonHidden(true)

                    } label: {
                        EmptyView()
                    }
                    .hidden()
                    
                    Text("Iniciar sesión")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    LabelField(systemName: "person.crop.circle", title: "Nombre de usuario / Email / número telefonico"){
                        TextField("Nombre de usuario / Email / número telefonico", text: $identifier)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textContentType(.username)
                            .keyboardType(.default)
                    }
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    LabelField(systemName: "lock.fill", title: "Contraseña"){
                        HStack{
                            Group{
                                if showPass{
                                    TextField("Contraseña", text: $password)
                                }
                                else {
                                    SecureField("••••••••", text: $password)
                                }
                            }
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            Button {
                                showPass.toggle()
                            } label: {
                                Image(systemName: showPass ? "eye.slash" : "eye")
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel(showPass ? "Hide password" : "Show password")
                        }
                    }
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    
                    Button{
                        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
                        let normalized = trimmed.contains("@") ? trimmed.lowercased() : trimmed
                        
                        let loginUser = LoginRequest(
                            identifier: normalized,
                            password: password
                        )
                        Task {
                            await loginVM.login(user: loginUser)
                        }
                    }
                    label: {
                        Text("Iniciar sesión")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                    }
                    Divider()
                    HStack{
                        Text("¿No tienes cuenta?")
                            .frame(maxWidth: .infinity)
                        NavigationLink{
                            RegisterView()
                        } label: {
                            Text("Crea una aquí")
                                .frame(maxWidth: .infinity)
                        }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    }
                        
                }
            }
        }
        .onChange(of: loginVM.errorMessage) { newValue in
            showError = newValue != nil
        }
        .alert("Login error", isPresented: $showError) {
            Button("OK", role: .cancel) { showError = false }
        } message: {
            Text(loginVM.errorMessage ?? "Ocurrió un error")
        }
        
    }
}

#Preview {
    LoginView()
}

