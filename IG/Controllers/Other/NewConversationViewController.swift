//
//  NewConversationViewController.swift
//  IG
//
//  Created by James Estrada on 8/5/21.
//

import UIKit
import JGProgressHUD

final class NewConversationViewController: UIViewController, SearchResultsViewControllerDelegate, UISearchResultsUpdating {
    
    public var completion: ((User) -> (Void))?
    
    private let searchVC = UISearchController(searchResultsController: SearchResultsViewController())
    
    private let spinner = JGProgressHUD()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        (searchVC.searchResultsController as? SearchResultsViewController)?.delegate = self
        searchVC.searchBar.placeholder = "Search..."
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.searchVC.searchBar.becomeFirstResponder()
        }
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    func searchResultsViewController(_ VC: SearchResultsViewController, didSelectResultWith user: User) {

        self.completion?(user)
        
//        let vc = ChatViewController(user: user, id: "123")
//        vc.isNewConversation = true
//        vc.title = "from searchresultsviewcontroller"
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        DatabaseManager.shared.findUsers(with: query) { results in
            DispatchQueue.main.async {
                resultsVC.update(with: results)
            }
        }
    }
}
