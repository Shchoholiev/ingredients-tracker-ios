//
//  Device.swift
//  SmartInventorySystem
//
//  Created by Serhii Shchoholiev on 12/5/23.
//

import Foundation

struct Device : Codable, Identifiable {
    var id: String
    var name: String?
    var type: DeviceType
    var guid: String
    var groupId: String?
    var isActive: Bool
}

enum DeviceType: Int, Codable {
    case unknown = 0 // To enforce API users to set type explicitly
    case productsRecognizer = 1
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let typeValue = try container.decode(Int.self)

        switch typeValue {
        case 1:
            self = .productsRecognizer
        default:
            self = .unknown
        }
    }
    
    func toString() -> String {
        switch self {
        case .unknown:
            return "Unknown"
        case .productsRecognizer:
            return "Products Recognizer"
        }
    }
}

struct DeviceStatus : Codable {
    var groupId: String
    var isActive: Bool
}

struct DeviceCreateDto: Codable {
    var id: String
    var name: String
    var type: DeviceType
    var guid: String
}
