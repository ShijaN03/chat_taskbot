//
//  APIClient.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    private let baseURL = "https://interesnoitochka.ru/api/v1"
    private let session = URLSession.shared
    private let keychain = KeychainService.shared
    
    private var isRefreshing = false
    private var refreshQueue: [(Result<Void, Error>) -> Void] = []
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        headers: [String: String]? = nil,
        requiresAuth: Bool = true,
        responseType: T.Type
    ) async throws -> T {
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let sessionId = keychain.sessionId {
            request.setValue(sessionId, forHTTPHeaderField: "X-Session-ID")
        }
        if requiresAuth, let accessToken = keychain.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        if httpResponse.statusCode == 401 && requiresAuth {
            try await refreshTokenIfNeeded()
            return try await self.request(
                endpoint: endpoint,
                method: method,
                body: body,
                headers: headers,
                requiresAuth: requiresAuth,
                responseType: responseType
            )
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw APIClientError.apiError(apiError)
            }
            throw APIClientError.httpError(statusCode: httpResponse.statusCode)
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIClientError.decodingError(error)
        }
    }
    
    func requestFormURLEncoded<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .post,
        parameters: [String: String],
        responseType: T.Type
    ) async throws -> T {
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIClientError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func refreshTokenIfNeeded() async throws {
        guard let refreshToken = keychain.refreshToken else {
            throw APIClientError.noRefreshToken
        }
        
        let tokenResponse: TokenResponse = try await requestFormURLEncoded(
            endpoint: "/auth/jwt/refresh/new",
            parameters: ["token": refreshToken],
            responseType: TokenResponse.self
        )
        keychain.accessToken = tokenResponse.accessToken
        if let newRefreshToken = tokenResponse.refreshToken {
            keychain.refreshToken = newRefreshToken
        }
    }
}
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
enum APIClientError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case apiError(APIError)
    case noRefreshToken
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .apiError(let error):
            return error.localizedDescription
        case .noRefreshToken:
            return "No refresh token available"
        case .notAuthenticated:
            return "User not authenticated"
        }
    }
}