//
//  Product.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

struct Product: Codable, Identifiable, Hashable {
    var id: String = ""
    var name: String = ""
    var count: Int = 0
}

struct ProductCount: Encodable {
    var count: Int
}
