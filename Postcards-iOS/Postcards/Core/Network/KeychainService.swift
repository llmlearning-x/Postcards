import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    private init() {}
    
    var accessToken: String? {
        get { get(.accessToken) }
        set { set(newValue, for: .accessToken) }
    }
    
    var refreshToken: String? {
        get { get(.refreshToken) }
        set { set(newValue, for: .refreshToken) }
    }
    
    func clear() {
        KeychainItem.allCases.forEach { delete($0) }
    }
    
    private enum KeychainItem: String, CaseIterable {
        case accessToken = "postcards.access_token"
        case refreshToken = "postcards.refresh_token"
    }
    
    private func get(_ item: KeychainItem) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func set(_ value: String?, for item: KeychainItem) {
        guard let value = value else {
            delete(item)
            return
        }
        
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func delete(_ item: KeychainItem) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}
