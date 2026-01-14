//
//  NewMessageWorker.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

protocol NewMessageWorkerProtocol {
    func searchUsers(query: String) async throws -> [UserAPIModel]
    func getRecommendedUsers() async throws -> [UserAPIModel]
}

final class NewMessageWorker: NewMessageWorkerProtocol {
    
    private let api = APIClient.shared
    
    func searchUsers(query: String) async throws -> [UserAPIModel] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        print("🔍 Searching users with query: \(query)")
        let response: UserSearchResponse = try await api.request(
            endpoint: "/users/search?q=\(encodedQuery)",
            method: .get,
            requiresAuth: true,
            responseType: UserSearchResponse.self
        )
        print("🔍 Found \(response.allUsers.count) users")
        return response.allUsers
    }
    
    func getRecommendedUsers() async throws -> [UserAPIModel] {
        // Use search with empty or popular query for recommendations
        let response: UserSearchResponse = try await api.request(
            endpoint: "/users/search",
            method: .get,
            requiresAuth: true,
            responseType: UserSearchResponse.self
        )
        return response.allUsers
    }
}
