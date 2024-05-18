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

     private var service = ProductsService()
     
     var body: some View {
         NavigationView {
             if isLoading {
                 // Used to make full screen gray when loading
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
                                     
                                     Text("\(product.count)")
                                         .font(.subheadline)
                                     
                                     Spacer()
                                     
                                     NavigationLink(value: product) {
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
}

#Preview {
    ProductsView()
}
