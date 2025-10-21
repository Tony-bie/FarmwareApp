//
//  RegisterView.swift
//  RoyaApp
//
//  Created by Alumno on 30/09/25.
//

import SwiftUI

struct RegisterView : View {
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var username  = ""
    @State private var emailNumber     = ""
    @State private var password  = ""
    @State private var confirm   = ""
    @State private var dateAdded = Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    @State private var showPass  = false
    @State private var showConfirmPass = false
    @State private var showError = false
    @State private var showSuccess = false
    @State private var acceptTerms = false
    
    private var emailRegex: Regex<Substring> { /.+@.+\..+/ }
    private var phoneRegex: Regex<Substring> { /^\d{10}$/ }
    
    private enum ContactValidationState {
        case empty
        case valid
        case invalidEmail
        case invalidPhone
    }
    
    private var contactValidation: (state: ContactValidationState, message: String?) {
        let trimmed = emailNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (.empty, nil)
        }
        
        let looksLikePhone = trimmed.allSatisfy(\.isNumber)
        let looksLikeEmail = trimmed.contains("@") || trimmed.contains(where: { $0.isLetter })
        
        if looksLikePhone {
            if trimmed.wholeMatch(of: phoneRegex) != nil {
                return (.valid, "Número telefónico válido")
            } else {
                return (.invalidPhone, "Número telefónico inválido (10 números)")
            }
        } else if looksLikeEmail {
            if trimmed.wholeMatch(of: emailRegex) != nil {
                return (.valid, "Valid email")
            } else {
                return (.invalidEmail, "Correo válido")
            }
        } else {
            return (.invalidEmail, "Correo inválido")
        }
    }
    
    private var passwordsMatch: Bool{
        !password.isEmpty && password == confirm
    }
    
    private var passwordStrength : Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .punctuationCharacters.union(.symbols)) != nil { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        return min(score, 4)
    }
    
    private var areNamesNonEmpty: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    private var isPasswordNonEmpty: Bool { !password.isEmpty && !confirm.isEmpty }
    private var isUsernameNonEmpty: Bool { !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    private var isvalidEverything: Bool {
        let contactOK = contactValidation.state == .empty || contactValidation.state == .valid
        return areNamesNonEmpty &&
               isUsernameNonEmpty &&
               isPasswordNonEmpty && passwordsMatch &&
               acceptTerms &&
               contactOK
    }
    @StateObject private var viewModel = RegisterViewModel()

    var body: some View {
        NavigationStack{
            ZStack{
                Color.appBg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16){
                        Text("Crear nueva cuenta")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading,15)
                            .padding(.trailing, 15)
                        LabelField(systemName: "person.fill", title: "Nombre(s)"){
                            TextField("Nombre(s)", text: $firstName)
                        }
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        LabelField(systemName: "person", title: "Apellidos"){
                            TextField("Apellidos", text: $lastName)
                        }
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        
                        LabelField(systemName: "person.crop.circle", title: "Nombre de usuario"){
                            TextField("Nombre de usuario", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        
                        HStack {
                            Text("Fecha de nacimiento")
                                .font(.headline)
                            DatePicker("", selection: $dateAdded, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        
                        LabelField(systemName: "envelope.fill", title: "Correo o número telefónico"){
                            TextField("Correo electrónico o número de teléfono", text: $emailNumber)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                        }
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        
                        Group {
                            switch contactValidation.state {
                            case .empty:
                                EmptyView()
                            case .valid:
                                validityTag(isValid: true, text: "Valid email/phone")
                            case .invalidEmail:
                                validityTag(isValid: false, text: "Correo inválido")
                            case .invalidPhone:
                                validityTag(isValid: false, text: "Número telefónico valido")
                            }
                        }
                        
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
                        strengthMeter(score: passwordStrength)
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        LabelField(systemName: "lock.rotation", title: "Repetir contraseña"){
                            HStack{
                                Group{
                                    if showConfirmPass{
                                        TextField("Repetir contraseña", text: $confirm)
                                    }
                                    else {
                                        SecureField("•••••••••••••", text: $confirm)
                                    }
                                }
                                .textContentType(.newPassword)
                                .textInputAutocapitalization(.never)
                                Button {
                                    showConfirmPass.toggle()
                                } label: {
                                    Image(systemName: showConfirmPass ? "eye.slash" : "eye")
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityLabel(showConfirmPass ? "Hide password" : "Show password")
                            }
                            
                        }
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                        validityTag(isValid: passwordsMatch, text: passwordsMatch ? "Contraseña verificada" : "Contraseña no verificada")
                        
                        Toggle(isOn: $acceptTerms) {
                            Text("Acepto los términos y condiciones")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 15)
                        
                        Button{
                            guard isvalidEverything else {return}
                            let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                            let birthdayString = formatter.string(from: dateAdded)
                            let trimmed = emailNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            let emailToSend: String? = trimmed.contains("@") ? trimmed.lowercased() : nil
                            let phoneToSend: String? = trimmed.allSatisfy(\.isNumber) ? trimmed : nil
                            
                            let newUser = RegisterUser(
                                first_name: firstName,
                                last_name: lastName,
                                username: username,
                                email: emailToSend,
                                phonenumber: phoneToSend,
                                password: password,
                                birthday: birthdayString
                            )

                            Task {
                                await viewModel.register(user: newUser)
                            }
                        }
                        label: {
                            Text("Crear cuenta")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                         }
                        .disabled(!isvalidEverything)
                        .onChange(of: viewModel.errorMessage){ _, newValue in
                                showError = newValue != nil
                            }
                            .alert("Error en la creación de la cuenta", isPresented: $showError) {
                                Button("OK", role: .cancel) { showError = false }
                            } message: {
                                Text(viewModel.errorMessage ?? "Ocurrió un error")
                            }
                        
                        Spacer(minLength: 8)
                    }
                    .padding(.vertical, 16)
                }
            }
            
        }
        .onChange(of: viewModel.registrationSuccess) { _, newValue in
            if newValue {
                showSuccess = true
            }
        }
        .alert("Registro exitoso", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                showSuccess = false
                viewModel.registrationSuccess = false
            }
        } message: {
            Text("Tu cuenta se creó correctamente.")
        }
    }
}

#Preview {
    RegisterView()
}


struct LabelField <Content: View>: View {
    let systemName: String
    let title: String
    let content: () -> Content
    
    init(systemName: String, title: String, @ViewBuilder content: @escaping () -> Content) {
            self.systemName = systemName
            self.title = title
            self.content = content
        }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8){
                Image(systemName: systemName)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
            }
            content()
                .textFieldStyle(.roundedBorder)
        }
    }
}

func validityTag(isValid: Bool, text: String) -> some View {
       HStack(spacing: 6) {
           Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
           Text(text)
               .font(.footnote)
               .lineLimit(1)
       }
       .foregroundStyle(isValid ? .green : .red)
       .padding(.vertical, 2)
       .accessibilityHidden(true)
   }
func strengthMeter(score: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Contraseña fuerte")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .frame(height: 6)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(i < score ? .green : .gray.opacity(0.3))
                }
            }
            .accessibilityLabel("Puntuación de seguridad: \(score) de 4")
            .accessibilityHidden(false)
            Text("Usa 8 o más letras, mayúsculas, minúsculas, simbolos y números")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

