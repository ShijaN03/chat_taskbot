//
//  NewMessageInteractor.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

final class NewMessageInteractor: NewMessageInteractorInputProtocol {
    
    weak var presenter: NewMessageInteractorOutputProtocol?
    private let worker: NewMessageWorkerProtocol
    
    init(worker: NewMessageWorkerProtocol = NewMessageWorker()) {
        self.worker = worker
    }
    
    func fetchRecommendedUsers() {
        Task {
            do {
                let apiUsers = try await worker.getRecommendedUsers()
                let users = apiUsers.map { mapToEntity($0) }
                
                await MainActor.run {
                    presenter?.didFetchRecommendedUsers(users)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFetchRecommendedUsers([])
                }
            }
        }
    }
    
    func searchUsers(with query: String) {
        guard !query.isEmpty else {
            fetchRecommendedUsers()
            return
        }
        
        Task {
            do {
                let apiUsers = try await worker.searchUsers(query: query)
                let users = apiUsers.map { mapToEntity($0) }
                
                await MainActor.run {
                    presenter?.didSearchUsers(users)
                }
            } catch {
                await MainActor.run {
                    presenter?.didSearchUsers([])
                }
            }
        }
    }
    
    private func mapToEntity(_ api: UserAPIModel) -> UserEntity {
        return UserEntity(
            id: api.id,
            username: api.telegramUsername ?? api.name ?? "user",
            displayName: api.name,
            avatarURL: api.avatar,
            accountType: .personal,
            isVerified: false
        )
    }
}