//
//  ChatFilterViewController.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

protocol ChatFilterDelegate: AnyObject {
    func didApplyFilters(_ filters: ChatFilters)
}

struct ChatFilters {
    var dateFrom: Date?
    var dateTo: Date?
    var filterOperator: FilterOperator
    
    enum FilterOperator: Int {
        case any = 0
        case exact = 1
        case like = 2
    }
}

final class ChatFilterViewController: UIViewController {
    
    weak var delegate: ChatFilterDelegate?
    private var filters = ChatFilters(dateFrom: nil, dateTo: nil, filterOperator: .any)
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 1)
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сбросить все", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dateSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dateSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Период поиска"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateFromLabel: UILabel = {
        let label = UILabel()
        label.text = "С"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateFromButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(formatDate(Date()), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = UIColor(white: 0.18, alpha: 1)
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.addTarget(self, action: #selector(dateFromTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }()
    
    private lazy var dateToLabel: UILabel = {
        let label = UILabel()
        label.text = "По"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateToButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(formatDate(Date()), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = UIColor(white: 0.18, alpha: 1)
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.addTarget(self, action: #selector(dateToTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }()
    
    private lazy var dateSeparatorLabel: UILabel = {
        let label = UILabel()
        label.text = "–"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var operatorSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var operatorLabel: UILabel = {
        let label = UILabel()
        label.text = "Оператор"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var operatorStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var anyButton: UIButton = createOperatorButton(title: "Любой", tag: 0)
    private lazy var exactButton: UIButton = createOperatorButton(title: "Равно", tag: 1)
    private lazy var likeButton: UIButton = createOperatorButton(title: "Лайк", tag: 2)
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Показать 3 чата", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.25, green: 0.45, blue: 0.85, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateOperatorButtons()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1)
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.addSubview(handleView)
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(resetButton)
        
        view.addSubview(dateSectionView)
        dateSectionView.addSubview(dateSectionLabel)
        dateSectionView.addSubview(dateFromLabel)
        dateSectionView.addSubview(dateFromButton)
        dateSectionView.addSubview(dateSeparatorLabel)
        dateSectionView.addSubview(dateToLabel)
        dateSectionView.addSubview(dateToButton)
        
        view.addSubview(operatorSectionView)
        operatorSectionView.addSubview(operatorLabel)
        operatorSectionView.addSubview(operatorStackView)
        
        operatorStackView.addArrangedSubview(anyButton)
        operatorStackView.addArrangedSubview(exactButton)
        operatorStackView.addArrangedSubview(likeButton)
        
        view.addSubview(applyButton)
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 36),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            headerView.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            resetButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            resetButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            dateSectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            dateSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateSectionLabel.topAnchor.constraint(equalTo: dateSectionView.topAnchor, constant: 16),
            dateSectionLabel.leadingAnchor.constraint(equalTo: dateSectionView.leadingAnchor, constant: 16),
            
            dateFromLabel.topAnchor.constraint(equalTo: dateSectionLabel.bottomAnchor, constant: 12),
            dateFromLabel.leadingAnchor.constraint(equalTo: dateSectionView.leadingAnchor, constant: 16),
            
            dateFromButton.topAnchor.constraint(equalTo: dateFromLabel.bottomAnchor, constant: 6),
            dateFromButton.leadingAnchor.constraint(equalTo: dateSectionView.leadingAnchor, constant: 16),
            dateFromButton.heightAnchor.constraint(equalToConstant: 40),
            dateFromButton.bottomAnchor.constraint(equalTo: dateSectionView.bottomAnchor, constant: -16),
            
            dateSeparatorLabel.centerYAnchor.constraint(equalTo: dateFromButton.centerYAnchor),
            dateSeparatorLabel.centerXAnchor.constraint(equalTo: dateSectionView.centerXAnchor),
            
            dateToLabel.topAnchor.constraint(equalTo: dateSectionLabel.bottomAnchor, constant: 12),
            dateToLabel.leadingAnchor.constraint(equalTo: dateSeparatorLabel.trailingAnchor, constant: 20),
            
            dateToButton.topAnchor.constraint(equalTo: dateToLabel.bottomAnchor, constant: 6),
            dateToButton.leadingAnchor.constraint(equalTo: dateSeparatorLabel.trailingAnchor, constant: 20),
            dateToButton.trailingAnchor.constraint(equalTo: dateSectionView.trailingAnchor, constant: -16),
            dateToButton.heightAnchor.constraint(equalToConstant: 40),
            dateToButton.widthAnchor.constraint(equalTo: dateFromButton.widthAnchor),
            
            dateFromButton.trailingAnchor.constraint(equalTo: dateSeparatorLabel.leadingAnchor, constant: -20),
            operatorSectionView.topAnchor.constraint(equalTo: dateSectionView.bottomAnchor, constant: 12),
            operatorSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            operatorSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            operatorLabel.topAnchor.constraint(equalTo: operatorSectionView.topAnchor, constant: 16),
            operatorLabel.leadingAnchor.constraint(equalTo: operatorSectionView.leadingAnchor, constant: 16),
            
            operatorStackView.topAnchor.constraint(equalTo: operatorLabel.bottomAnchor, constant: 12),
            operatorStackView.leadingAnchor.constraint(equalTo: operatorSectionView.leadingAnchor, constant: 16),
            operatorStackView.trailingAnchor.constraint(lessThanOrEqualTo: operatorSectionView.trailingAnchor, constant: -16),
            operatorStackView.bottomAnchor.constraint(equalTo: operatorSectionView.bottomAnchor, constant: -16),
            operatorStackView.heightAnchor.constraint(equalToConstant: 36),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createOperatorButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1)
        button.layer.cornerRadius = 18
        button.tag = tag
        button.addTarget(self, action: #selector(operatorTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        return button
    }
    
    @objc private func resetTapped() {
        filters = ChatFilters(dateFrom: nil, dateTo: nil, filterOperator: .any)
        dateFromButton.setTitle(formatDate(Date()), for: .normal)
        dateToButton.setTitle(formatDate(Date()), for: .normal)
        updateOperatorButtons()
    }
    
    @objc private func dateFromTapped() {
        showDatePicker(isFrom: true)
    }
    
    @objc private func dateToTapped() {
        showDatePicker(isFrom: false)
    }
    
    @objc private func operatorTapped(_ sender: UIButton) {
        filters.filterOperator = ChatFilters.FilterOperator(rawValue: sender.tag) ?? .any
        updateOperatorButtons()
    }
    
    @objc private func applyTapped() {
        delegate?.didApplyFilters(filters)
        dismiss(animated: true)
    }
    
    private func updateOperatorButtons() {
        let buttons = [anyButton, exactButton, likeButton]
        
        for button in buttons {
            if button.tag == filters.filterOperator.rawValue {
                button.backgroundColor = UIColor(white: 0.35, alpha: 1)
            } else {
                button.backgroundColor = UIColor(white: 0.2, alpha: 1)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    private func showDatePicker(isFrom: Bool) {
        let alert = UIAlertController(title: isFrom ? "Дата С" : "Дата По", message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        alert.view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        let height: NSLayoutConstraint = NSLayoutConstraint(
            item: alert.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 320
        )
        alert.view.addConstraint(height)
        
        alert.addAction(UIAlertAction(title: "Готово", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if isFrom {
                self.filters.dateFrom = datePicker.date
                self.dateFromButton.setTitle(self.formatDate(datePicker.date), for: .normal)
            } else {
                self.filters.dateTo = datePicker.date
                self.dateToButton.setTitle(self.formatDate(datePicker.date), for: .normal)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func updateResultCount(_ count: Int) {
        applyButton.setTitle("Показать \(count) чата", for: .normal)
    }
}