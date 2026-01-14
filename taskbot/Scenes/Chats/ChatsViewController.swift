//
//  ChatsViewController.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatsViewController: UIViewController, ChatsViewProtocol {
    var presenter: ChatsPresenterProtocol?
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("@shijan", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        let chevron = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        button.setImage(chevron, for: .normal)
        button.tintColor = .white
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var composeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(named: "new_chat"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(composeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Поиск"
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: "Поиск", attributes: [.foregroundColor: UIColor.gray])
        textField.delegate = self
        textField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.setImage(UIImage(systemName: "slider.horizontal.3", withConfiguration: config), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tabsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messagesTabButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сообщения", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.tag = 0
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var archiveTabButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Архив", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.tag = 1
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tabIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var tabIndicatorLeadingConstraint: NSLayoutConstraint?
    private var tabIndicatorWidthConstraint: NSLayoutConstraint?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var customTabBar: CustomTabBar = {
        let tabBar = CustomTabBar()
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()
    
    private var chats: [ChatViewModel] = []
    private var selectedTabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
        
        // Enable WebSocket for real-time messages
        if KeychainService.shared.isAuthenticated {
            setupChatWebSocket()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTabIndicator(animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(headerView)
        headerView.addSubview(usernameButton)
        headerView.addSubview(composeButton)
        
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchIconView)
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(filterButton)
        
        view.addSubview(tabsContainerView)
        tabsContainerView.addSubview(messagesTabButton)
        tabsContainerView.addSubview(archiveTabButton)
        tabsContainerView.addSubview(tabIndicatorView)
        
        view.addSubview(tableView)
        view.addSubview(customTabBar)
        view.addSubview(activityIndicator)
        
        let indicatorLeading = tabIndicatorView.leadingAnchor.constraint(equalTo: messagesTabButton.leadingAnchor)
        let indicatorWidth = tabIndicatorView.widthAnchor.constraint(equalToConstant: 80)
        tabIndicatorLeadingConstraint = indicatorLeading
        tabIndicatorWidthConstraint = indicatorWidth
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            usernameButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            usernameButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            composeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            composeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            composeButton.widthAnchor.constraint(equalToConstant: 44),
            composeButton.heightAnchor.constraint(equalToConstant: 44),
            searchContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            searchIconView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 10),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 18),
            searchIconView.heightAnchor.constraint(equalToConstant: 18),
            
            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -8),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            
            filterButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -10),
            filterButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 24),
            filterButton.heightAnchor.constraint(equalToConstant: 24),
            tabsContainerView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 16),
            tabsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabsContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            messagesTabButton.leadingAnchor.constraint(equalTo: tabsContainerView.leadingAnchor, constant: 16),
            messagesTabButton.topAnchor.constraint(equalTo: tabsContainerView.topAnchor),
            
            archiveTabButton.leadingAnchor.constraint(equalTo: messagesTabButton.trailingAnchor, constant: 24),
            archiveTabButton.topAnchor.constraint(equalTo: tabsContainerView.topAnchor),
            
            indicatorLeading,
            indicatorWidth,
            tabIndicatorView.bottomAnchor.constraint(equalTo: tabsContainerView.bottomAnchor),
            tabIndicatorView.heightAnchor.constraint(equalToConstant: 3),
            tableView.topAnchor.constraint(equalTo: tabsContainerView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor, constant: -8),
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateTabIndicator(animated: Bool) {
        let selectedButton = selectedTabIndex == 0 ? messagesTabButton : archiveTabButton
        
        tabIndicatorLeadingConstraint?.isActive = false
        tabIndicatorLeadingConstraint = tabIndicatorView.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor)
        tabIndicatorLeadingConstraint?.isActive = true
        
        tabIndicatorWidthConstraint?.constant = selectedButton.intrinsicContentSize.width
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func composeTapped() {
        presenter?.didTapCompose()
    }
    
    @objc private func tabTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index != selectedTabIndex else { return }
        
        selectedTabIndex = index
        messagesTabButton.setTitleColor(index == 0 ? .white : .gray, for: .normal)
        messagesTabButton.titleLabel?.font = .systemFont(ofSize: 16, weight: index == 0 ? .semibold : .regular)
        
        archiveTabButton.setTitleColor(index == 1 ? .white : .gray, for: .normal)
        archiveTabButton.titleLabel?.font = .systemFont(ofSize: 16, weight: index == 1 ? .semibold : .regular)
        
        updateTabIndicator(animated: true)
        
        let segment = ChatSegment(rawValue: index) ?? .messages
        presenter?.didSelectSegment(segment)
    }
    
    @objc private func searchTextChanged() {
        presenter?.didSearchChats(with: searchTextField.text ?? "")
    }
    
    @objc private func pullToRefresh() {
        presenter?.didPullToRefresh()
    }
    
    @objc private func filterTapped() {
        let filterVC = ChatFilterViewController()
        filterVC.delegate = self
        filterVC.updateResultCount(chats.count)
        
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 20
        }
        
        present(filterVC, animated: true)
    }
    
    func showChats(_ chats: [ChatViewModel]) {
        self.chats = chats
        tableView.reloadData()
        refreshControl.endRefreshing()
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
        refreshControl.endRefreshing()
    }
    
    func updateUnreadCount(for chatId: String, count: Int) {
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        
        let chat = chats[indexPath.row]
        cell.configure(with: chat)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectChat(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let chat = chats[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let archive = UIAction(
                title: "В архив",
                image: UIImage(systemName: "archivebox")
            ) { _ in
                self.presenter?.didTapArchive(chatId: chat.id)
            }
            
            let markUnread = UIAction(
                title: "Непрочитанное",
                image: UIImage(systemName: "envelope.badge")
            ) { _ in
                self.presenter?.didTapMarkUnread(chatId: chat.id)
            }
            
            let delete = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.presenter?.didTapDelete(chatId: chat.id)
            }
            
            return UIMenu(children: [archive, markUnread, delete])
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = UIColor(white: 0.2, alpha: 1)
        parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 12)
        
        return UITargetedPreview(view: cell, parameters: parameters)
    }
}

extension ChatsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension ChatsViewController: ChatFilterDelegate {
    
    func didApplyFilters(_ filters: ChatFilters) {
        presenter?.didApplyFilters(
            dateFrom: filters.dateFrom,
            dateTo: filters.dateTo,
            filterOperator: filters.filterOperator.rawValue
        )
    }
}
extension ChatsViewController: CustomTabBarDelegate {
    
    func didSelectTab(_ index: Int) {

    }
}

extension ChatsViewController: ChatWebSocketDelegate {
    
    func setupChatWebSocket() {
        ChatWebSocketManager.shared.delegate = self
        ChatWebSocketManager.shared.connectToAllChats()
    }
    
    func chatWebSocketDidConnect() {
        print("✅ Ready to receive messages")
    }
    
    func chatWebSocketDidReceiveMessage(_ message: ChatMessageEvent) {
        print("📩 NEW MESSAGE RECEIVED:")
        print("   Type: \(message.type ?? "unknown")")
        print("   Chat ID: \(message.chatId ?? "unknown")")
        print("   Sender: \(message.senderId ?? "unknown")")
        print("   Content: \(message.content ?? message.message?.content ?? "no content")")
        
        presenter?.viewDidLoad()
    }
    
    func chatWebSocketDidDisconnect() {
        print("🔌 Chat WebSocket disconnected")
    }
    
    func chatWebSocketDidFail(with error: Error) {
        print("❌ Chat WebSocket error: \(error.localizedDescription)")
    }
}
