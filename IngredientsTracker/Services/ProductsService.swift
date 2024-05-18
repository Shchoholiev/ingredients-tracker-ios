//
//  ProductsService.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

class ProductsService: ServiceBase {
    
    init() {
        super.init(url: "/products")
    }
    
    func getProductsPage(groupId: String, page: Int = 1, size: Int = 20, search: String) async throws -> PagedList<Product> {
        let url = "\(baseUrl)?page=\(page)&size=\(size)&groupId=\(groupId)&search=\(search)"
        let items: PagedList<Product> = try await HttpClient.shared.getAsync(url)
        
        return items
    }
}
