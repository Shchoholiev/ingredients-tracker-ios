//
//  RecipesService.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

class RecipesService: ServiceBase {
    
    init() {
        super.init(url: "/recipes")
    }
    
    func getRecipesPage(groupId: String, page: Int = 1, size: Int = 20, search: String) async throws -> PagedList<Recipe> {
        let url = "\(baseUrl)?page=\(page)&size=\(size)&groupId=\(groupId)&search=\(search)"
        let recipes: PagedList<Recipe> = try await HttpClient.shared.getAsync(url)
        
        return recipes
    }
    
    func getRecipe(recipeId: String) async throws -> Recipe {
        let url = "\(baseUrl)/\(recipeId)"
        let recipe: Recipe = try await HttpClient.shared.getAsync(url)
        
        return recipe
    }
    
    func cookRecipe(recipeId: String) async throws {
        let url = "\(baseUrl)/\(recipeId)/cook"
        let _: Dummy = try await HttpClient.shared.patchAsync(url, nil as Dummy?)
    }
}
