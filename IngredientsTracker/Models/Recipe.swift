//
//  Recipe.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

struct Recipe: Decodable, Identifiable, Hashable {
    var id: String = ""
    var name: String = ""
    var thumbnail: ImageInfo?
    var text: String = ""
    var ingredients: [Product] = []
    var categories: [Category] = []
}
