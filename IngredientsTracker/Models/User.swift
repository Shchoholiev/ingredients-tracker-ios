//
//  User.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    var id: String
    var name: String?
    var phone: String?
    var email: String?
    var groupId: String?
    var roles: [Role]
}
