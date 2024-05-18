//
//  PagedList.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

struct PagedList<T : Decodable> : Decodable {
    
    let totalPages: Int
    
    let items: [T]
    
    init(totalPages: Int, items: [T]) {
        self.totalPages = totalPages
        self.items = items
    }
}
