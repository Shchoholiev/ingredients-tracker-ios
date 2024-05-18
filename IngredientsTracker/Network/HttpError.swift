//
//  HttpError.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

struct HttpError: Error, Codable {
    let message: String
}
