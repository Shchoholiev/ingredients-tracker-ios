//
//  Config.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/19/24.
//

import Foundation

/// A singleton class that manages configuration settings for the app.
class Config {
    static let shared = Config()
    var imageStorageUrl: String = ""
    var apiUrl: String = ""
    
    /// Initializes the Config instance by loading settings from a property list.
    private init() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let config = try? PropertyListDecoder().decode([String: String].self, from: xml) {
            apiUrl = config["ApiUrl"] ?? ""
            imageStorageUrl = config["ImageStorageUrl"] ?? ""
        }
    }
}
