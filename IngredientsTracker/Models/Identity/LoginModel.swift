//
//  LoginModel.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

class LoginModel: Codable {
    var email: String?
    var phone: String?
    var password: String
    
    public init(_ email: String? = nil, _ phone: String? = nil, _ password: String) {
        self.email = email
        self.phone = phone
        self.password = password
    }
}
