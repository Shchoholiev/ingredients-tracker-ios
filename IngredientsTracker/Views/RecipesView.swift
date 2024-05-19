//
//  RecipesView.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import SwiftUI

struct RecipesView: View {
    private var groupId = GlobalUser.shared.groupId ?? ""
    @State private var recipes: [Recipe] = []
    
    @State private var searchText = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = true

    private var service = RecipesService()
    
    var body: some View {
        NavigationView {
            if isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color(UIColor.systemGroupedBackground))
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        if recipes.count > 0 {
                            ForEach($recipes, id: \.id) { $recipe in
                                HStack(alignment: .center) {
                                    Text(recipe.name)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    NavigationLink(value: recipe) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundStyle(.blue)
                                            .font(.system(size: 24))
                                    }
                                }
                                .padding([.top, .bottom], 13)
                                .padding([.leading, .trailing], 17)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                            
                        } else {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("No recipes")
                                        .foregroundStyle(.gray)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing, .bottom])
                    .padding([.top], 5)
                    .background(Color(UIColor.systemGroupedBackground))
                }
                .background(Color(UIColor.systemGroupedBackground))
                .navigationBarTitle("Search recipes")
                .searchable(text: $searchText, prompt: "Search for recipes")
                .onChange(of: searchText) { oldValue, newValue in
                    loadData()
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    /// Loads the data for the view by fetching a page of recipes from the service.
    private func loadData() {
        Task {
            do {
                let page = try await service.getRecipesPage(groupId: groupId, size: 100, search: searchText)
                self.recipes = page.items

                isLoading = false
            } catch let httpError as HttpError {
                errorMessage = httpError.message
                isLoading = false
            }
        }
    }
}

#Preview {
    RecipesView()
}
