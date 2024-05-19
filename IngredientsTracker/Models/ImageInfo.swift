//
//  Image.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

struct ImageInfo: Decodable, Hashable {
    var id: String = ""
    var originalPhotoGuid: String = ""
    var smallPhotoGuid: String = ""
    var `extension`: String = ""
    var md5Hash: String = ""
    var imageUploadState: ImageUploadState = .started
}

enum ImageUploadState: Int, Decodable, Hashable {
    case started = 0
    case uploaded
    case failed
}
