//
//  RecipeDetailsView.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import SwiftUI

struct RecipeDetailsView: View {
    var recipe: Recipe
    @State private var image: UIImage? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isError = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()
                
                if let thumbnail = recipe.thumbnail {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } else {
                        ProgressView()
                            .onAppear {
                                loadImage(from: thumbnail)
                            }
                    }
                }
                
                Text("Ingredients")
                    .font(.title2)
                    .bold()
                
                ForEach(recipe.ingredients, id: \.id) { ingredient in
                    HStack {
                        Text(ingredient.name)
                        Spacer()
                        Text("\(ingredient.count)")
                    }
                    .padding(.vertical, 2)
                }
                
                Text("Instructions")
                    .font(.title2)
                    .bold()
                
                Text(recipe.text)
                    .padding(.vertical, 2)
                
                Text("Categories")
                    .font(.title2)
                    .bold()
                
                ForEach(recipe.categories, id: \.id) { category in
                    Text(category.name)
                        .padding(.vertical, 2)
                }
                
                Button(action: {
                    Task {
                        await cookRecipe()
                    }
                }) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.white)
                        Text("Cook Recipe")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(isError ? "Error" : "Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    /// Loads an image from the given ImageInfo object.
    /// - Parameter imageInfo: The ImageInfo object containing the URL information of the image.
    func loadImage(from imageInfo: ImageInfo) {
        guard !imageInfo.originalPhotoGuid.isEmpty else {
            return
        }
        
        let urlString = "\(Config.shared.imageStorageUrl)/\(imageInfo.originalPhotoGuid).\(imageInfo.extension)"
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            } else {
                DispatchQueue.main.async {
                    self.image = nil
                }
            }
        }
        
        task.resume()
    }
    
    /// Initiates the cooking process for the recipe and shows an alert upon completion or error.
    func cookRecipe() async {
        do {
            let service = RecipesService()
            let _ = try await service.cookRecipe(recipeId: recipe.id)
            alertMessage = "Cooked!"
            isError = false
        } catch let error as HttpError {
            alertMessage = error.message
            isError = true
        } catch {
            alertMessage = error.localizedDescription
            isError = true
        }
        showAlert = true
    }
}

#Preview {
    RecipeDetailsView(recipe: Recipe(id: "1", name: "Sample Recipe", ingredients: [Product(id: "1", name: "Sample Ingredient", count: 1)], categories: [Category(id: "1", name: "Sample Category")]))
}
