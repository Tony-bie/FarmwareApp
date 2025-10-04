//
//  LoginView.swift
//  RoyaApp
//
//  Created by Alumno on 30/09/25.
//

import SwiftUI




struct LoginView : View {
    @State private var forgotPassword: Bool = false
    @State private var email     = ""
    @State private var password  = ""
    @State private var showPass  = false
    @StateObject private var loginVM = LoginModel()
    
    @State private var showError = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.appBg.ignoresSafeArea()
                VStack(alignment: .leading){
                    Text("Login session")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    LabelField(systemName: "envelope.fill", title: "Email"){
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                    }
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    LabelField(systemName: "lock.fill", title: "Password"){
                        HStack{
                            Group{
                                if showPass{
                                    TextField("Password", text: $password)
                                }
                                else {
                                    SecureField("••••••••", text: $password)
                                }
                            }
                            .textContentType(.newPassword)
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
                        let loginUser = LoginRequest(email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), password: password)
                        Task {
                            await loginVM.login(user: loginUser)
                        }
                    }
                    label: {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                    }
                    
                    HStack(alignment: .center){
                        Button(action:{forgotPassword.toggle()}){
                            Text("Did you forget your password?")
                                .font(.footnote)
                                .underline()
                        }
                        Spacer()
                        NavigationLink{
                            RegisterView()
                        } label: {
                            Text("Sign up")
                                .font(.footnote)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
            }
        }
        .onChange(of: loginVM.errorMessage){ _, newValue in
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

