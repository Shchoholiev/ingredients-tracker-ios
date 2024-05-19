//
//  ProductsView.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import SwiftUI

struct ProductsView: View {
    private var groupId = GlobalUser.shared.groupId ?? ""
    @State private var products: [Product] = []
    
    @State private var searchText = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = true
    @State private var editingProductId: String? = nil

    private var service = ProductsService()
    
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
                        if products.count > 0 {
                            ForEach($products, id: \.id) { $product in
                                HStack(alignment: .center) {
                                    Text(product.name)
                                        .font(.headline)
                                    
                                    if editingProductId == product.id {
                                        TextField("New count", value: $product.count, formatter: NumberFormatter())
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.numberPad)
                                            .frame(width: 60)
                                    } else {
                                        Text("\(product.count)")
                                            .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    if editingProductId == product.id {
                                        Button(action: {
                                            updateProductCount(product)
                                        }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                                .font(.system(size: 24))
                                        }
                                    }
                                    
                                    Button(action: {
                                        if editingProductId == product.id {
                                            editingProductId = nil
                                        } else {
                                            editingProductId = product.id
                                        }
                                    }) {
                                        Image(systemName: editingProductId == product.id ? "xmark.circle.fill" : "pencil.circle.fill")
                                            .foregroundStyle(editingProductId == product.id ? .red : .blue)
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
                                    Text("No products")
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
                .navigationBarTitle("Search products")
                .searchable(text: $searchText, prompt: "Search for products")
                .onChange(of: searchText) { oldValue, newValue in
                    loadData()
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    /// Loads the data for the view by fetching a page of products from the service.
    private func loadData() {
        Task {
            do {
                let page = try await service.getProductsPage(groupId: groupId, size: 100, search: searchText)
                self.products = page.items

                isLoading = false
            } catch let httpError as HttpError {
                errorMessage = httpError.message
                isLoading = false
            }
        }
    }
    
    /// Updates the count of a given product by calling the service to update it.
    /// - Parameter product: The product to update the count for.
    private func updateProductCount(_ product: Product) {
        Task {
            do {
                let updatedProduct = try await service.updateProductCount(productId: product.id, count: product.count)
                if let index = products.firstIndex(where: { $0.id == product.id }) {
                    products[index] = updatedProduct
                }
                editingProductId = nil
            } catch let httpError as HttpError {
                errorMessage = httpError.message
            }
        }
    }
}

#Preview {
    ProductsView()
}
