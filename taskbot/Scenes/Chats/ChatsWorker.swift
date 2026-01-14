//
//  ChatsWorker.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

protocol ChatsWorkerProtocol {
    func fetchChats() async throws -> [ChatAPIModel]
    func fetchArchivedChats() async throws -> [ChatAPIModel]
    func archiveChat(chatId: Int) async throws
    func unarchiveChat(chatId: Int) async throws
    func markChatRead(chatId: Int) async throws
    func deleteChat(chatId: Int) async throws
    func fetchMessages(chatId: Int) async throws -> [MessageAPIModel]
    func sendMessage(recipientId: Int, content: String) async throws -> SendMessageResponse
    func sendMessageByUsername(username: String, content: String) async throws -> SendMessageResponse
}

final class ChatsWorker: ChatsWorkerProtocol {
    
    private let apiClient = APIClient.shared
    
    func fetchChats() async throws -> [ChatAPIModel] {
        let response: ChatsResponse = try await apiClient.request(
            endpoint: "/chats?offset=0&limit=50",
            method: .get,
            requiresAuth: true,
            responseType: ChatsResponse.self
        )
        // Filter to only in-inbox chats
        return (response.chats ?? []).filter { $0.isInInbox == true }
    }
    
    func fetchArchivedChats() async throws -> [ChatAPIModel] {
        let response: ChatsResponse = try await apiClient.request(
            endpoint: "/chats?offset=0&limit=50",
            method: .get,
            requiresAuth: true,
            responseType: ChatsResponse.self
        )
        // Filter to archived (not in inbox)
        return (response.chats ?? []).filter { $0.isInInbox != true }
    }
    
    func archiveChat(chatId: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)/archive",
            method: .put,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func unarchiveChat(chatId: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)/inbox",
            method: .put,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func markChatRead(chatId: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)/read",
            method: .post,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func deleteChat(chatId: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)",
            method: .delete,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func fetchMessages(chatId: Int) async throws -> [MessageAPIModel] {
        let response: [MessageAPIModel] = try await apiClient.request(
            endpoint: "/chats/\(chatId)/messages",
            method: .get,
            requiresAuth: true,
            responseType: [MessageAPIModel].self
        )
        return response
    }
    
    func sendMessage(recipientId: Int, content: String) async throws -> SendMessageResponse {
        let body = SendMessageRequest(recipientId: recipientId, content: content)
        let bodyData = try JSONEncoder().encode(body)
        
        return try await apiClient.request(
            endpoint: "/chats/messages",
            method: .post,
            body: bodyData,
            requiresAuth: true,
            responseType: SendMessageResponse.self
        )
    }
    
    func sendMessageByUsername(username: String, content: String) async throws -> SendMessageResponse {
        let body = SendMessageRequest(username: username, content: content)
        let bodyData = try JSONEncoder().encode(body)
        
        return try await apiClient.request(
            endpoint: "/chats/messages",
            method: .post,
            body: bodyData,
            requiresAuth: true,
            responseType: SendMessageResponse.self
        )
    }
}
