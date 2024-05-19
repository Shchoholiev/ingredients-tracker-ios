//
//  UserDetailsView.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import SwiftUI

struct UserDetailsView: View {
    @State var user: User
    
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userPhone: String = ""
    
    @State private var roleName: String = ""
    
    @State private var errorMessage: String? = nil
    @State private var isEditMode = false

    private var usersService = UsersService()
    
    init(user: User) {
        self.user = user
        _userName = State(initialValue: user.name ?? "")
        _userEmail = State(initialValue: user.email ?? "")
        _userPhone = State(initialValue: user.phone ?? "")
    }
    
    var body: some View {
        VStack {
            Form {
                Section("User") {
                    TextField("Name", text: $userName)
                        .disabled(!isEditMode)
                    TextField("Phone", text: $userPhone)
                        .disabled(!isEditMode)
                    TextField("Email", text: $userEmail)
                        .disabled(!isEditMode)
                }
            }
            .frame(height: 185)
            
            HStack {
                TextField("Role Name", text: $roleName)
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom], 5)
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                Button {
                    addRole()
                } label: {
                    Text("Add role")
                        .foregroundColor(.white)
                }
                .padding([.trailing, .leading], 15)
                .padding([.top, .bottom], 7)
                .background(.blue)
                .cornerRadius(40)
                .disabled(roleName.isEmpty)
            }
            .padding([.leading, .trailing], 21)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(user.roles, id: \.id) { role in
                        HStack {
                            HStack() {
                                Text(role.name)
                                    .font(.headline)
                            }

                            Spacer()

                            Button {
                                deleteRole(role)
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding([.top, .bottom], 10)
                        .padding([.leading, .trailing])
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    }
                }
                .padding([.leading, .trailing], 21)
                .padding(.top, 7)
            }
            
            if let message = errorMessage {
                Text(message)
                    .foregroundColor(.red)
                    .padding([.trailing, .leading], 15)
            }
            
            Spacer()
        }
        .padding([.bottom, .leading, .trailing])
        .navigationTitle(user.name ?? user.email ?? user.phone ?? "")
        .navigationBarItems(trailing:
            Button {
                toggleEdit()
            } label: {
                if !isEditMode {
                    Image(systemName: "square.and.pencil")
                } else {
                    Text("Save")
                }
            }
            .font(.system(size: 16, design: .default))
        )
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    /// Toggles edit mode and updates user details if edit mode is being disabled.
    private func toggleEdit() {
        Task {
            do {
                if self.isEditMode {
                    user.name = userName
                    user.email = userEmail
                    user.phone = userPhone
                    
                    let updatedUser = try await usersService.updateUser(userId: user.id, user: user)
                    self.user = updatedUser
                }
                
                isEditMode = !self.isEditMode
                errorMessage = nil
            } catch let httpError as HttpError {
                errorMessage = httpError.message
            }
        }
    }
    
    /// Adds a role to the user.
    private func addRole() {
        Task {
            do {
                let updatedUser = try await usersService.addUserRole(userId: user.id, roleName: roleName)
                self.user = updatedUser
                
                roleName = ""
                errorMessage = nil
            } catch let httpError as HttpError {
                errorMessage = httpError.message
            }
        }
    }
    
    /// Deletes a role from the user.
    /// - Parameter role: The role to be deleted.
    private func deleteRole(_ role: Role) {
        Task {
            do {
                let updatedUser = try await usersService.removeUserRole(userId: user.id, roleName: role.name)
                self.user = updatedUser
                
                errorMessage = nil
            } catch let httpError as HttpError {
                errorMessage = httpError.message
            }
        }
    }
}

#Preview {
    UserDetailsView(user: User(id: "", roles: [Role(id: "", name: "User")]))
}
