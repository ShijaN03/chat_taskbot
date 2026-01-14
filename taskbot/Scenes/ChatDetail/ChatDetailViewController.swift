//
//  ChatDetailViewController.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatDetailViewController: UIViewController, ChatDetailViewProtocol {
    var presenter: ChatDetailPresenterProtocol?
    
    private lazy var headerView: ChatDetailHeaderView = {
        let view = ChatDetailHeaderView()
        view.onBackTapped = { [weak self] in
            self?.presenter?.didTapBack()
        }
        view.onProfileTapped = { [weak self] in
            self?.presenter?.didTapUserProfile()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: TextMessageCell.identifier)
        tableView.register(MediaMessageCell.self, forCellReuseIdentifier: MediaMessageCell.identifier)
        tableView.register(RepostMessageCell.self, forCellReuseIdentifier: RepostMessageCell.identifier)
        tableView.register(DateHeaderCell.self, forCellReuseIdentifier: DateHeaderCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var inputContainerView: ChatInputView = {
        let view = ChatInputView()
        view.onSendMessage = { [weak self] text in
            self?.presenter?.didSendMessage(text: text)
        }
        view.onAttachmentTapped = { [weak self] in
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mutualStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = "Вы подписаны друг на друга"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var viewProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Посмотреть профиль", for: .normal)
        button.setTitleColor(UIColor(red: 0.3, green: 0.6, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(viewProfileTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var registrationDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(white: 0.5, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var inputBottomConstraint: NSLayoutConstraint!
    
    private var messages: [MessageViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1)
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(inputContainerView)
        view.addSubview(activityIndicator)
        
        emptyStateView.addSubview(emptyAvatarImageView)
        emptyStateView.addSubview(emptyNameLabel)
        emptyStateView.addSubview(mutualStatusLabel)
        emptyStateView.addSubview(viewProfileButton)
        emptyStateView.addSubview(registrationDateLabel)
        
        inputBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            emptyAvatarImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyAvatarImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 60),
            emptyAvatarImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyAvatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyNameLabel.topAnchor.constraint(equalTo: emptyAvatarImageView.bottomAnchor, constant: 16),
            emptyNameLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 20),
            emptyNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -20),
            
            mutualStatusLabel.topAnchor.constraint(equalTo: emptyNameLabel.bottomAnchor, constant: 8),
            mutualStatusLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            viewProfileButton.topAnchor.constraint(equalTo: mutualStatusLabel.bottomAnchor, constant: 16),
            viewProfileButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            registrationDateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor, constant: -20),
            registrationDateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: 80),
            inputBottomConstraint,
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func viewProfileTapped() {
        presenter?.didTapUserProfile()
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        inputBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        inputBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showMessages(_ messages: [MessageViewModel]) {
        self.messages = messages.reversed()
        tableView.reloadData()
        let isEmpty = messages.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    func appendMessage(_ message: MessageViewModel) {
        messages.insert(message, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
    
    func showUserInfo(name: String, status: String, avatarURL: String?) {
        headerView.configure(name: name, status: status, avatarURL: avatarURL)
    }
    
    func showEmptyState(name: String, avatarURL: String?, registrationDate: String) {
        emptyNameLabel.text = name
        registrationDateLabel.text = "taskbot c \(registrationDate)"
        if let urlString = avatarURL, let _ = URL(string: urlString) {
        }
        
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: animated)
    }
}
extension ChatDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        switch message.type {
        case .text:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageCell.identifier, for: indexPath) as? TextMessageCell else {
                return UITableViewCell()
            }
            cell.configure(with: message)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
            
        case .repost:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RepostMessageCell.identifier, for: indexPath) as? RepostMessageCell else {
                return UITableViewCell()
            }
            cell.configure(with: message)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
            
        case .photo, .video, .voice, .location:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MediaMessageCell.identifier, for: indexPath) as? MediaMessageCell else {
                return UITableViewCell()
            }
            cell.configure(with: message)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}