//
//  AuthManager.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

final class AuthManager {
    
    static let shared = AuthManager()
    
    private let apiClient = APIClient.shared
    private let keychain = KeychainService.shared
    private let webSocket = WebSocketManager.shared
    
    private init() {}
    
    var isAuthenticated: Bool {
        return keychain.accessToken != nil
    }
    
    var hasSession: Bool {
        return keychain.sessionId != nil
    }
    
    var currentSessionId: String? {
        return keychain.sessionId
    }
    
    var authState: AuthState {
        if let accessToken = keychain.accessToken,
           let refreshToken = keychain.refreshToken {
            return .authenticated(accessToken: accessToken, refreshToken: refreshToken)
        } else if let sessionId = keychain.sessionId {
            return .anonymous(sessionId: sessionId)
        } else {
            return .none
        }
    }
    
    func getAnonymousSession() async throws -> SessionResponse {
        let session: SessionResponse = try await apiClient.request(
            endpoint: "/auth/sessions/new",
            method: .get,
            requiresAuth: false,
            responseType: SessionResponse.self
        )
        keychain.sessionId = session.id
        
        return session
    }
    
    func startWebSocketLogin(delegate: WebSocketManagerDelegate) throws {
        guard let sessionId = keychain.sessionId else {
            throw AuthError.noSessionId
        }
        
        webSocket.delegate = delegate
        webSocket.connect(sessionId: sessionId)
    }
    
    func stopWebSocketLogin() {
        webSocket.disconnect()
    }
    
    func saveTokens(_ tokens: TokenResponse) {
        keychain.accessToken = tokens.accessToken
        if let refreshToken = tokens.refreshToken {
            keychain.refreshToken = refreshToken
        }
    }
    
    func refreshAccessToken() async throws -> TokenResponse {
        guard let refreshToken = keychain.refreshToken else {
            throw AuthError.noRefreshToken
        }
        
        let tokenResponse: TokenResponse = try await apiClient.requestFormURLEncoded(
            endpoint: "/auth/jwt/refresh/new",
            parameters: ["token": refreshToken],
            responseType: TokenResponse.self
        )
        saveTokens(tokenResponse)
        
        return tokenResponse
    }
    
    func logout() {
        keychain.clearAll()
    }
    
    func getQRCodeURL() -> String? {
        guard let sessionId = keychain.sessionId else { return nil }
        return "https://t.me/chatttinnngggbot?start=\(sessionId)"
    }
}
enum AuthError: Error, LocalizedError {
    case noSessionId
    case noRefreshToken
    case loginFailed
    
    var errorDescription: String? {
        switch self {
        case .noSessionId:
            return "No session ID available. Please restart the app."
        case .noRefreshToken:
            return "No refresh token available. Please log in again."
        case .loginFailed:
            return "Login failed. Please try again."
        }
    }
}