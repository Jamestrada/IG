//
//  NotificationsViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private var viewModels: [NotificationCellType] = []
    
    // MARK: - Lifecycle
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(FollowNotificationTableViewCell.self, forCellReuseIdentifier: FollowNotificationTableViewCell.identifier)
        table.register(LikeNotificationTableViewCell.self, forCellReuseIdentifier: LikeNotificationTableViewCell.identifier)
        table.register(CommentNotificationTableViewCell.self, forCellReuseIdentifier: CommentNotificationTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(noActivityLabel)
        fetchNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func fetchNotifications() {
        noActivityLabel.isHidden = false
    }
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowNotificationTableViewCell.identifier, for: indexPath) as? FollowNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LikeNotificationTableViewCell.identifier, for: indexPath) as? LikeNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentNotificationTableViewCell.identifier, for: indexPath) as? CommentNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
    }
}
