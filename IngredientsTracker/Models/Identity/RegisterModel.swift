//
//  RegisterModel.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

class RegisterModel: Codable {
    var name: String?
    var email: String?
    var phone: String?
    var password: String
    
    public init(_ name: String? = nil, _ email: String? = nil, _ phone: String? = nil, _ password: String) {
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
    }
}
