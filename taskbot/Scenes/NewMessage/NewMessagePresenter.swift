//
//  NewMessagePresenter.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

final class NewMessagePresenter: NewMessagePresenterProtocol {
    
    weak var view: NewMessageViewProtocol?
    var interactor: NewMessageInteractorInputProtocol?
    var router: NewMessageRouterProtocol?
    
    func viewDidLoad() {
        view?.showLoading()
        interactor?.fetchRecommendedUsers()
    }
    
    func didSearchUsers(with query: String) {
        if query.isEmpty {
            interactor?.fetchRecommendedUsers()
        } else {
            interactor?.searchUsers(with: query)
        }
    }
    
    func didSelectUser(_ user: UserViewModel) {
        router?.navigateToChat(with: user.id, userName: user.username)
    }
    
    private func mapToViewModels(_ entities: [UserEntity]) -> [UserViewModel] {
        return entities.map { entity in
            UserViewModel(
                id: entity.id,
                username: entity.username,
                displayName: entity.displayName,
                avatarURL: entity.avatarURL,
                accountType: entity.accountType.displayName,
                isVerified: entity.isVerified
            )
        }
    }
}

extension NewMessagePresenter: NewMessageInteractorOutputProtocol {
    
    func didFetchRecommendedUsers(_ users: [UserEntity]) {
        let viewModels = mapToViewModels(users)
        view?.hideLoading()
        view?.showRecommendations(viewModels)
    }
    
    func didSearchUsers(_ users: [UserEntity]) {
        let viewModels = mapToViewModels(users)
        view?.hideLoading()
        view?.showUsers(viewModels)
    }
    
    func didFailFetching(with error: Error) {
        view?.hideLoading()
        view?.showError(error.localizedDescription)
    }
}