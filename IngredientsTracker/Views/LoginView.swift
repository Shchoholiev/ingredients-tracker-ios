//
//  LoginView.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    
    @State private var errorMessage: String? = nil
    
    @Binding var showLogin: Bool
    
    private var usersService = UsersService()
    
    public init(showLogin: Binding<Bool>) {
        self._showLogin = showLogin
    }

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)

            TextField("Email", text: $email)
                .padding(12)
                .foregroundColor(.primary)
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(7)

            TextField("Phone", text: $phone)
                .padding(12)
                .foregroundColor(.primary)
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(7)

            SecureField("Password", text: $password)
                .padding(12)
                .foregroundColor(.primary)
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(7)
            
            HStack {
                Button(action: {
                    Task {
                        await loginUser()
                    }
                }) {
                    Text("Login")
                        .frame(minWidth: 0, maxWidth: 100)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .padding()
                        .foregroundColor(.white)
                        .background(.blue)
                        .opacity(isFormValid ? 1 : 0.5)
                        .cornerRadius(40)
                }
                .disabled(!isFormValid)
                .padding()
                
                Button(action: {
                    showLogin = false
                }) {
                    Text("Register")
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding()
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding(30)
    }
    
    /// A computed property that checks if the login form is valid.
    /// - Returns: A boolean indicating if the form is valid.
    var isFormValid: Bool {
        (!email.isEmpty || !phone.isEmpty) && !password.isEmpty
    }

    /// Logs in the user using the provided email, phone, and password.
    func loginUser() async {
        let loginModel = LoginModel(email, phone, password)
        do {
            _ = try await usersService.login(loginModel)
            errorMessage = nil
        } catch let httpError as HttpError {
            errorMessage = httpError.message
        } catch {
            errorMessage = "Something went wrong"
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showLogin: .constant(true))
    }
}
