//
//  HttpClient.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation

/// A service class for making HTTP requests and managing user authentication.
class HttpClient: ObservableObject {
    
    /// The shared instance of the HttpClient class.
    static let shared = HttpClient()
    
    /// The base URL for the API.
    private let baseUrl = URL(string: Config.shared.apiUrl)!
    
    /// A service for managing JWT tokens.
    private let jwtTokensService = JwtTokensService()
    
    /// The access token for authorization.
    private var accessToken: String?
    
    /// A service for managing user-related operations.
    private var usersService = UsersService()
    
    /// A published property indicating whether the user is authenticated.
    @Published var isAuthenticated = false
    
    /// Sends a GET request to the specified path and decodes the response.
    /// - Parameter path: The path to send the request to.
    /// - Returns: The decoded response of type `TOut`.
    func getAsync<TOut: Decodable>(_ path: String) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await sendAsync(path, nil as Dummy?, .get)
    }
    
    /// Sends a DELETE request to the specified path and decodes the response.
    /// - Parameter path: The path to send the request to.
    /// - Returns: The decoded response of type `TOut`.
    func deleteAsync<TOut: Decodable>(_ path: String) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await sendAsync(path, nil as Dummy?, .delete)
    }
    
    /// Sends a POST request with data to the specified path and decodes the response.
    /// - Parameters:
    ///   - path: The path to send the request to.
    ///   - data: The data to send in the request body.
    /// - Returns: The decoded response of type `TOut`.
    func postAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await sendAsync(path, data, .post)
    }
    
    /// Sends a PUT request with data to the specified path and decodes the response.
    /// - Parameters:
    ///   - path: The path to send the request to.
    ///   - data: The data to send in the request body.
    /// - Returns: The decoded response of type `TOut`.
    func putAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await sendAsync(path, data, .put)
    }
    
    /// Sends a PATCH request with data to the specified path and decodes the response.
    /// - Parameters:
    ///   - path: The path to send the request to.
    ///   - data: The data to send in the request body.
    /// - Returns: The decoded response of type `TOut`.
    func patchAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await sendAsync(path, data, .patch)
    }
    
    /// Logs out the user by clearing authentication data and tokens.
    func logout() {
        Task {
            await setAuthenticated(false)
        }
        jwtTokensService.clearTokensInKeychain()
        accessToken = nil
        UserDefaults.standard.removeObject(forKey: "groupId")
        GlobalUser.shared.clear()
    }
    
    /// Sets the authentication state.
    /// - Parameter value: A boolean indicating whether the user is authenticated.
    func setAuthenticated(_ value: Bool) async {
        await MainActor.run {
            isAuthenticated = value
        }
    }
    
    /// Checks if the user is authenticated by validating the access token.
    func checkAuthentication() async {
        await checkAccessTokenAsync()
        do {
            let user: User = try await getAsync("/users/\(GlobalUser.shared.email ?? GlobalUser.shared.phone ?? "")")
            await GlobalUser.shared.setGroupId(user.groupId)
            await setAuthenticated(true)
        } catch {
        }
    }
    
    /// Refreshes the user's authentication by obtaining new tokens.
    func refreshUserAuthentication() async {
        let tokensModel = await getTokensAsync()
        if let tokens = tokensModel {
            jwtTokensService.storeTokensInKeychain(tokens: tokens)
            GlobalUser.shared.setUserFromJwt(tokens.accessToken)
            accessToken = tokens.accessToken
            await setAuthenticated(true)
        }
    }
    
    /// Sends an HTTP request and decodes the response.
    /// - Parameters:
    ///   - path: The path to send the request to.
    ///   - data: The data to send in the request body (optional).
    ///   - httpMethod: The HTTP method to use for the request.
    /// - Returns: The decoded response of type `TOut`.
    private func sendAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn?, _ httpMethod: HttpMethod) async throws -> TOut {
        do {
            let url = URL(string: baseUrl.absoluteString + path)!
            print(url)
            
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jwt = accessToken {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            }
            
            if let inputData = data {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(inputData)
                request.httpBody = jsonData
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let httpResponse = response as! HTTPURLResponse
            print(httpResponse.statusCode)
            if !(200...299).contains(httpResponse.statusCode) {
                let httpError = try decoder.decode(HttpError.self, from: data)
                throw httpError
            }
            
            do {
                let object = try decoder.decode(TOut.self, from: data)
                return object
            } catch {
                print(error)
                return Dummy() as! TOut
            }
        } catch {
            print(error)
            throw error
        }
    }
    
    /// Checks the validity of the access token and refreshes it if necessary.
    private func checkAccessTokenAsync() async {
        var tokensModel: TokensModel? = nil
        if jwtTokensService.isExpired() {
            tokensModel = await getTokensAsync()
            if let tokens = tokensModel {
                jwtTokensService.storeTokensInKeychain(tokens: tokens)
            }
            await setAuthenticated(true)
        } else {
            tokensModel = jwtTokensService.getTokensFromKeychain()
        }
        if let tokens = tokensModel {
            GlobalUser.shared.setUserFromJwt(tokens.accessToken)
            accessToken = tokens.accessToken
        } else {
            await setAuthenticated(false)
        }
    }
    
    /// Retrieves the tokens from the Keychain and refreshes them if needed.
    /// - Returns: An optional TokensModel containing the access and refresh tokens.
    private func getTokensAsync() async -> TokensModel? {
        let tokensModel = jwtTokensService.getTokensFromKeychain()
        if let tokens = tokensModel, !tokens.accessToken.isEmpty, !tokens.refreshToken.isEmpty {
            return await refreshTokens(tokens)
        }
        
        return nil
    }
    
    /// Refreshes the access and refresh tokens.
    /// - Parameter tokens: The current TokensModel containing the access and refresh tokens.
    /// - Returns: An optional TokensModel containing the new access and refresh tokens.
    private func refreshTokens(_ tokens: TokensModel) async -> TokensModel? {
        do {
            let tokens: TokensModel = try await sendAsync("/tokens/refresh", tokens, .post)
            return tokens
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    /// Converts a PascalCase string to camelCase.
    /// - Parameter pascalKey: The PascalCase string.
    /// - Returns: The camelCase string.
    private func convertPascalToCamelCase(_ pascalKey: String) -> String {
        let firstChar = pascalKey.prefix(1).lowercased()
        let otherChars = pascalKey.dropFirst()
        return "\(firstChar)\(otherChars)"
    }
    
    struct AnyCodingKey: CodingKey {
        let stringValue: String
        let intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
}

/// An enumeration representing HTTP methods.
enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// A struct used to pass empty data in sendAsync() from getAsync().
struct Dummy: Codable {
}
