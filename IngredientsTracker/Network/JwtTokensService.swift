//
//  JwtTokensService.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import Foundation
import JWTDecode

/// A service class that handles storing, retrieving, and managing JWT tokens in the Keychain.
class JwtTokensService {
    
    /// The identifier for the access token in the Keychain.
    let accessTokenIdentifier = "accessToken"
    
    /// The identifier for the refresh token in the Keychain.
    let refreshTokenIdentifier = "refreshToken"
    
    /// Stores the given tokens in the Keychain and updates the global user state.
    /// - Parameter tokens: The TokensModel containing the access and refresh tokens.
    func storeTokensInKeychain(tokens: TokensModel) {
        GlobalUser.shared.setUserFromJwt(tokens.accessToken)
        storeTokenInKeychain(accessTokenIdentifier, tokens.accessToken)
        storeTokenInKeychain(refreshTokenIdentifier, tokens.refreshToken)
    }
    
    /// Clears the tokens from the Keychain.
    func clearTokensInKeychain() {
        removeItemFromKeychain(accessTokenIdentifier)
        removeItemFromKeychain(refreshTokenIdentifier)
    }
    
    /// Checks if the access token is expired.
    /// - Returns: A boolean indicating whether the token is expired.
    func isExpired() -> Bool {
        let jwtTokens = getTokensFromKeychain()
        if let tokens = jwtTokens {
            do {
                let jwt = try decode(jwt: tokens.accessToken)
                let expirationDate = jwt.expiresAt
                let currentDate = getCurrentUTCDate()

                return expirationDate != nil && currentDate > expirationDate!
            } catch {
                print("Error decoding JWT token: \(error)")
            }
        }
        
        return true
    }
    
    /// Gets the current date in UTC format.
    /// - Returns: The current date in UTC.
    private func getCurrentUTCDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let utcDateString = dateFormatter.string(from: Date())
        return dateFormatter.date(from: utcDateString)!
    }
    
    /// Retrieves the tokens from the Keychain.
    /// - Returns: An optional TokensModel containing the access and refresh tokens.
    func getTokensFromKeychain() -> TokensModel? {
        let accessTokenValue = self.getTokenFromKeychain(accessTokenIdentifier)
        let refreshTokenValue = self.getTokenFromKeychain(refreshTokenIdentifier)
        
        if let accessToken = accessTokenValue,
           let refreshToken = refreshTokenValue {
            return TokensModel(accessToken: accessToken, refreshToken: refreshToken)
        }
        
        return nil
    }
    
    /// Retrieves a token from the Keychain.
    /// - Parameter identifier: The identifier for the token.
    /// - Returns: An optional string containing the token value.
    private func getTokenFromKeychain(_ identifier: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        } else {
            return nil
        }
    }
    
    /// Stores a token in the Keychain.
    /// - Parameters:
    ///   - identifier: The identifier for the token.
    ///   - value: The value of the token.
    private func storeTokenInKeychain(_ identifier: String, _ value: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: value.data(using: .utf8)!
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            if status == errSecDuplicateItem {
                let updateQuery: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: identifier
                ]
                
                let attributes: [String: Any] = [
                    kSecValueData as String: value.data(using: .utf8)!
                ]
                
                let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
                if updateStatus != errSecSuccess {
                    print("Error updating value of: \"\(identifier)\" in Keychain")
                }
            } else {
                print("Error storing value of: \"\(identifier)\" in Keychain")
            }
        }
    }
    
    /// Removes a token from the Keychain.
    /// - Parameter identifier: The identifier for the token.
    func removeItemFromKeychain(_ identifier: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnAttributes as String: true
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("Item removed successfully")
        } else if status == errSecItemNotFound {
            print("Item not found in Keychain")
        } else {
            print("Error removing item from Keychain: \(status)")
        }
    }
}
