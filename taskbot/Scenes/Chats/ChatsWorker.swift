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
    func fetchChatById(chatId: String) async throws -> ChatAPIModel
    func archiveChat(chatId: String) async throws
    func unarchiveChat(chatId: String) async throws
    func markChatRead(chatId: String) async throws
    func deleteChat(chatId: String) async throws
    func fetchMessages(chatId: String) async throws -> [MessageAPIModel]
    func sendMessage(chatId: String, content: String, type: String) async throws -> MessageAPIModel
}

final class ChatsWorker: ChatsWorkerProtocol {
    
    private let apiClient = APIClient.shared
    
    func fetchChats() async throws -> [ChatAPIModel] {
        do {
            let response: ChatListResponse = try await apiClient.request(
                endpoint: "/chats",
                method: .get,
                requiresAuth: true,
                responseType: ChatListResponse.self
            )
            return response.allChats.filter { $0.isArchived != true }
        } catch {
            let response: [ChatAPIModel] = try await apiClient.request(
                endpoint: "/chats",
                method: .get,
                requiresAuth: true,
                responseType: [ChatAPIModel].self
            )
            return response.filter { $0.isArchived != true }
        }
    }
    
    func fetchArchivedChats() async throws -> [ChatAPIModel] {
        do {
            let response: ChatListResponse = try await apiClient.request(
                endpoint: "/chats",
                method: .get,
                requiresAuth: true,
                responseType: ChatListResponse.self
            )
            return response.allChats.filter { $0.isArchived == true }
        } catch {
            let response: [ChatAPIModel] = try await apiClient.request(
                endpoint: "/chats",
                method: .get,
                requiresAuth: true,
                responseType: [ChatAPIModel].self
            )
            return response.filter { $0.isArchived == true }
        }
    }
    
    func fetchChatById(chatId: String) async throws -> ChatAPIModel {
        return try await apiClient.request(
            endpoint: "/chats/\(chatId)",
            method: .get,
            requiresAuth: true,
            responseType: ChatAPIModel.self
        )
    }
    
    func archiveChat(chatId: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)/archive",
            method: .put,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func unarchiveChat(chatId: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)/inbox",
            method: .put,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func markChatRead(chatId: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)/read",
            method: .post,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func deleteChat(chatId: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/chats/\(chatId)",
            method: .delete,
            requiresAuth: true,
            responseType: EmptyResponse.self
        )
    }
    
    func fetchMessages(chatId: String) async throws -> [MessageAPIModel] {
        return try await apiClient.request(
            endpoint: "/chats/\(chatId)/messages",
            method: .get,
            requiresAuth: true,
            responseType: [MessageAPIModel].self
        )
    }
    
    func sendMessage(chatId: String, content: String, type: String = "text") async throws -> MessageAPIModel {
        let bodyWithRecipient = SendMessageRequest(chatId: chatId, content: content, type: type)
        let bodyData = try JSONEncoder().encode(bodyWithRecipient)
        
        do {
            return try await apiClient.request(
                endpoint: "/chats/messages",
                method: .post,
                body: bodyData,
                requiresAuth: true,
                responseType: MessageAPIModel.self
            )
        } catch {
            let bodyWithChatId = SendMessageRequest(chatId: chatId, content: content, type: type)
            let bodyData2 = try JSONEncoder().encode(bodyWithChatId)
            
            return try await apiClient.request(
                endpoint: "/chats/messages",
                method: .post,
                body: bodyData2,
                requiresAuth: true,
                responseType: MessageAPIModel.self
            )
        }
    }
}
struct EmptyResponse: Codable {}
