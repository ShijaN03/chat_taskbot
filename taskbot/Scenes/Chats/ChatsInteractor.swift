//
//  ChatsInteractor.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

final class ChatsInteractor: ChatsInteractorInputProtocol {
    
    weak var presenter: ChatsInteractorOutputProtocol?
    
    private let worker: ChatsWorkerProtocol
    private var allChats: [ChatEntity] = []
    
    init(worker: ChatsWorkerProtocol = ChatsWorker()) {
        self.worker = worker
    }
        
    func fetchChats() {
        // Skip API if not authenticated
        guard KeychainService.shared.isAuthenticated else {
            print("ℹ️ Not authenticated, using mock data")
            let mockChats = createMockChats()
            allChats = mockChats.filter { !$0.isArchived }
            presenter?.didFetchChats(allChats)
            return
        }
        
        Task {
            do {
                let apiChats = try await worker.fetchChats()
                print("📱 Loaded \(apiChats.count) chats from API")
                let entities = apiChats.map { mapToEntity($0) }
                allChats = entities
                
                await MainActor.run {
                    presenter?.didFetchChats(entities)
                }
            } catch {
                print("⚠️ API error, using mock data: \(error.localizedDescription)")
                let mockChats = createMockChats()
                allChats = mockChats.filter { !$0.isArchived }
                
                await MainActor.run {
                    presenter?.didFetchChats(allChats)
                }
            }
        }
    }
    
    func searchChats(with query: String) {
        guard !query.isEmpty else {
            presenter?.didSearchChats(allChats)
            return
        }
        
        let filteredChats = allChats.filter { chat in
            chat.recipientName.lowercased().contains(query.lowercased()) ||
            (chat.lastMessage?.content.lowercased().contains(query.lowercased()) ?? false)
        }
        
        presenter?.didSearchChats(filteredChats)
    }
    
    func fetchArchivedChats() {
        guard KeychainService.shared.isAuthenticated else {
            let archivedChats = createMockChats().filter { $0.isArchived }
            presenter?.didFetchChats(archivedChats)
            return
        }
        
        Task {
            do {
                let apiChats = try await worker.fetchArchivedChats()
                let entities = apiChats.map { mapToEntity($0) }
                
                await MainActor.run {
                    presenter?.didFetchChats(entities)
                }
            } catch {
                let archivedChats = createMockChats().filter { $0.isArchived }
                await MainActor.run {
                    presenter?.didFetchChats(archivedChats)
                }
            }
        }
    }
    
    func markChatAsRead(chatId: String) {
        Task {
            do {
                try await worker.markChatRead(chatId: chatId)
                await MainActor.run {
                    presenter?.didMarkChatAsRead(chatId: chatId)
                }
            } catch {
                await MainActor.run {
                    presenter?.didMarkChatAsRead(chatId: chatId)
                }
            }
        }
    }
    
    func archiveChat(chatId: String) {
        Task {
            do {
                try await worker.archiveChat(chatId: chatId)
                await MainActor.run {
                    presenter?.didArchiveChat(chatId: chatId)
                }
            } catch {
                await MainActor.run {
                    presenter?.didArchiveChat(chatId: chatId)
                }
            }
        }
    }
    
    func markChatAsUnread(chatId: String) {
        Task {
            await MainActor.run {
                presenter?.didMarkChatAsUnread(chatId: chatId)
            }
        }
    }
    
    func deleteChat(chatId: String) {
        Task {
            do {
                try await worker.deleteChat(chatId: chatId)
                await MainActor.run {
                    presenter?.didDeleteChat(chatId: chatId)
                }
            } catch {
                await MainActor.run {
                    presenter?.didDeleteChat(chatId: chatId)
                }
            }
        }
    }
    
    private func mapToEntity(_ api: ChatAPIModel) -> ChatEntity {
        let dateFormatter = ISO8601DateFormatter()
        
        var lastMessage: ChatMessage? = nil
        if let apiMessage = api.lastMessage {
            lastMessage = ChatMessage(
                id: apiMessage.id,
                senderId: apiMessage.senderId ?? "",
                content: apiMessage.content ?? "",
                type: mapMessageType(apiMessage.type),
                createdAt: dateFormatter.date(from: apiMessage.createdAt ?? "") ?? Date(),
                isRead: apiMessage.isRead ?? true
            )
        }
        
        return ChatEntity(
            id: api.id,
            recipientId: api.recipientId ?? "",
            recipientName: api.recipientName ?? "Unknown",
            recipientAvatarURL: api.recipientAvatar,
            isVerified: api.recipientVerified ?? false,
            isOnline: false,
            lastMessage: lastMessage,
            unreadCount: api.unreadCount ?? 0,
            updatedAt: dateFormatter.date(from: api.updatedAt ?? "") ?? Date(),
            isArchived: api.isArchived ?? false
        )
    }
    
    private func mapMessageType(_ type: String?) -> ChatMessageType {
        switch type {
        case "photo": return .photo
        case "video": return .video
        case "voice": return .voice
        case "location": return .location
        case "publication": return .publication
        default: return .text
        }
    }
        
    private func createMockChats() -> [ChatEntity] {
        let now = Date()
        
        return [
            ChatEntity(
                id: "1",
                recipientId: "user1",
                recipientName: "nogotochki_48",
                recipientAvatarURL: "https://picsum.photos/seed/user1/100/100",
                isVerified: false,
                isOnline: true,
                lastMessage: ChatMessage(
                    id: "m1",
                    senderId: "user1",
                    content: "Приходите)",
                    type: .text,
                    createdAt: now,
                    isRead: false
                ),
                unreadCount: 0,
                updatedAt: now,
                isArchived: false
            ),
            ChatEntity(
                id: "2",
                recipientId: "user2",
                recipientName: "Lera234",
                recipientAvatarURL: "https://picsum.photos/seed/user2/100/100",
                isVerified: false,
                isOnline: false,
                lastMessage: ChatMessage(
                    id: "m2",
                    senderId: "user2",
                    content: "Отправил публикацию",
                    type: .publication,
                    createdAt: now.addingTimeInterval(-3600),
                    isRead: false
                ),
                unreadCount: 25,
                updatedAt: now.addingTimeInterval(-3600),
                isArchived: false
            ),
            ChatEntity(
                id: "3",
                recipientId: "user3",
                recipientName: "servise_car666",
                recipientAvatarURL: "https://picsum.photos/seed/user3/100/100",
                isVerified: true,
                isOnline: false,
                lastMessage: ChatMessage(
                    id: "m3",
                    senderId: "user3",
                    content: "Хорошо, договорились!",
                    type: .text,
                    createdAt: now.addingTimeInterval(-7200),
                    isRead: true
                ),
                unreadCount: 0,
                updatedAt: now.addingTimeInterval(-7200),
                isArchived: false
            ),
            ChatEntity(
                id: "4",
                recipientId: "user4",
                recipientName: "kristina2022",
                recipientAvatarURL: "https://picsum.photos/seed/user4/100/100",
                isVerified: false,
                isOnline: false,
                lastMessage: ChatMessage(
                    id: "m4",
                    senderId: "me",
                    content: "Просмотрено 1 ч. назад",
                    type: .text,
                    createdAt: now.addingTimeInterval(-3600),
                    isRead: true
                ),
                unreadCount: 0,
                updatedAt: now.addingTimeInterval(-3600),
                isArchived: false
            )
        ]
    }
}