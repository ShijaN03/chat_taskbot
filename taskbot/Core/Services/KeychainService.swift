//
//  KeychainService.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation
import Security

final class KeychainService {
    
    static let shared = KeychainService()
    
    private let service = "ru.interesnoitochka.taskbot"
    
    enum Key: String {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case sessionId = "sessionId"
    }
    
    private init() {}
    
    func save(_ value: String, for key: Key) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        delete(key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func get(_ key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    @discardableResult
    func delete(_ key: Key) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    func clearAll() {
        delete(.accessToken)
        delete(.refreshToken)
        delete(.sessionId)
    }
    
    var accessToken: String? {
        get { return get(.accessToken) }
        set {
            if let value = newValue {
                save(value, for: .accessToken)
            } else {
                delete(.accessToken)
            }
        }
    }
    
    var refreshToken: String? {
        get { return get(.refreshToken) }
        set {
            if let value = newValue {
                save(value, for: .refreshToken)
            } else {
                delete(.refreshToken)
            }
        }
    }
    
    var sessionId: String? {
        get { return get(.sessionId) }
        set {
            if let value = newValue {
                save(value, for: .sessionId)
            } else {
                delete(.sessionId)
            }
        }
    }
    
    var isAuthenticated: Bool {
        return accessToken != nil
    }
}