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
    @State private var email     = ""
    @State private var password  = ""
    @State private var confirm   = ""
    @State private var dateAdded = Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    @State private var showPass  = false
    @State private var showConfirmPass = false
    
    private var isEmailValid: Bool{
        let regex = /.+@.+\..+/
        return email.wholeMatch(of: regex) != nil
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
    
    private var isEmailNonEmpty: Bool { !email.trimmingCharacters(in: .whitespaces).isEmpty }
    private var areNamesNonEmpty: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    private var isPasswordNonEmpty: Bool { !password.isEmpty && !confirm.isEmpty }
    
    private var isvalidEverything: Bool {
        areNamesNonEmpty &&
        isEmailNonEmpty && isEmailValid &&
        isPasswordNonEmpty && passwordsMatch
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.appBg.ignoresSafeArea()
                VStack(spacing: 16){
                    Text("Create new account")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading,15)
                        .padding(.trailing, 15)
                    LabelField(systemName: "person.fill", title: "First name"){
                        TextField("First name", text: $firstName)
                    }
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    LabelField(systemName: "person", title: "Last name"){
                        TextField("Last name", text: $lastName)
                    }
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    HStack {
                        Text("Birthday")
                            .font(.headline)
                        DatePicker("", selection: $dateAdded, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    
                    LabelField(systemName: "envelope.fill", title: "Email"){
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                    }
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    validityTag(isValid: isEmailValid, text: isEmailValid ? "Valid email" : "Invalid email")
                    
                        
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
                    strengthMeter(score: passwordStrength)
                    .padding(.leading,15)
                    .padding(.trailing, 15)
                    LabelField(systemName: "lock.rotation", title: "Repeat password"){
                        HStack{
                            Group{
                                if showConfirmPass{
                                    TextField("Repeat password", text: $confirm)
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
                    validityTag(isValid: passwordsMatch, text: passwordsMatch ? "Passwords match" : "Passwords don’t match")
                    Button{
                        guard isvalidEverything else {return}
                    } label: {
                        Text("Create account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    }
                    .disabled(!isvalidEverything)
                    
                }
            }
            
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
            Text("Password strength")
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
            .accessibilityLabel("Password strength \(score) of 4")
            .accessibilityHidden(false)
            Text("Use 8+ chars with upper, lower, numbers, and symbols.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
