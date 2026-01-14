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
        guard KeychainService.shared.isAuthenticated else {
            presenter?.didFetchChats([])
            return
        }
        
        Task {
            do {
                let apiChats = try await worker.fetchChats()
                let entities = apiChats.map { mapToEntity($0) }
                allChats = entities
                
                await MainActor.run {
                    presenter?.didFetchChats(entities)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFetchChats([])
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
            presenter?.didFetchChats([])
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
                await MainActor.run {
                    presenter?.didFetchChats([])
                }
            }
        }
    }
    
    func markChatAsRead(chatId: String) {
        guard let intId = Int(chatId) else { return }
        Task {
            do {
                try await worker.markChatRead(chatId: intId)
                await MainActor.run {
                    presenter?.didMarkChatAsRead(chatId: chatId)
                }
            } catch { }
        }
    }
    
    func archiveChat(chatId: String) {
        guard let intId = Int(chatId) else { return }
        Task {
            do {
                try await worker.archiveChat(chatId: intId)
                await MainActor.run {
                    presenter?.didArchiveChat(chatId: chatId)
                }
            } catch { }
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
        guard let intId = Int(chatId) else { return }
        Task {
            do {
                try await worker.deleteChat(chatId: intId)
                await MainActor.run {
                    presenter?.didDeleteChat(chatId: chatId)
                }
            } catch { }
        }
    }
    
    private func mapToEntity(_ api: ChatAPIModel) -> ChatEntity {
        let dateFormatter = ISO8601DateFormatter()
        
        var lastMessage: ChatMessage? = nil
        if let apiMessage = api.lastMessage {
            lastMessage = ChatMessage(
                id: apiMessage.id ?? 0,
                senderId: apiMessage.senderId ?? 0,
                content: apiMessage.content ?? "",
                type: .text,
                createdAt: dateFormatter.date(from: apiMessage.createdAt ?? "") ?? Date(),
                isRead: apiMessage.isRead ?? true
            )
        }
        
        return ChatEntity(
            id: api.id,
            recipientId: api.otherUser?.id ?? 0,
            recipientName: api.otherUser?.name ?? api.name ?? "Unknown",
            recipientAvatarURL: api.otherUser?.avatarUrl ?? api.avatarUrl,
            isVerified: false,
            isOnline: false,
            lastMessage: lastMessage,
            unreadCount: api.unreadCount ?? 0,
            updatedAt: Date(),
            isArchived: api.isInInbox != true
        )
    }
}