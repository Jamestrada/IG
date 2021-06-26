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
    private var models: [IGNotification] = []
    
    // MARK: - Lifecycle
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
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
//        noActivityLabel.isHidden = false
        mockData()
    }
    
    private func mockData() {
        tableView.isHidden = false
        guard let postUrl = URL(string: "https://yourwikis.com/wp-content/uploads/2020/01/mark-zuck-img.jpg") else {
            return
        }
        guard let iconUrl = URL(string: "https://cdn3.iconfinder.com/data/icons/capsocial-round/500/facebook-512.png") else {
            return
        }
        
        viewModels = [
            .like(viewModel: LikeNotificationCellViewModel(username: "markzuckerberg", profilePictureUrl: iconUrl, postUrl: postUrl)),
            .comment(viewModel: CommentNotificationCellViewModel(username: "jeffbezos", profilePictureUrl: iconUrl, postUrl: postUrl)),
            .follow(viewModel: FollowNotificationCellViewModel(username: "billgates", profilePictureUrl: iconUrl, isCurrentUserFollowing: true))
        ]
        tableView.reloadData()
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
            cell.delegate = self
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LikeNotificationTableViewCell.identifier, for: indexPath) as? LikeNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentNotificationTableViewCell.identifier, for: indexPath) as? CommentNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        let username: String
        switch cellType {
        case .follow(let viewModel):
            username = viewModel.username
        case .like(viewModel: let viewModel):
            username = viewModel.username
        case .comment(viewModel: let viewModel):
            username = viewModel.username
        }
        
        DatabaseManager.shared.findUser(with: username) { [weak self] user in
            guard let user = user else {
                return
            }
            
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Actions

extension NotificationsViewController: FollowNotificationTableViewCellDelegate, LikeNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate {
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell, didTapButton isFollowing: Bool, viewModel: FollowNotificationCellViewModel) {
//        let username = viewModel.username
    }
    
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell, didTapPostWith viewModel: LikeNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .comment:
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else {
            return
        }
        
        openPost(with: index, username: viewModel.username)
        // Find post by id
    }
    
    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell, didTapPostWith viewModel: CommentNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .like:
                return false
            case .comment(let current):
                return current == viewModel
            }
        }) else {
            return
        }
        openPost(with: index, username: viewModel.username)
    }
    
    func openPost(with index: Int, username: String) {
        print(index)
        
        guard index < models.count else {
            return
        }
        let model = models[index]
        let username = username
        
        guard let postID = model.postId else {
            return
        }
    }
}
