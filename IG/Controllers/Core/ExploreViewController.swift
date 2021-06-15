//
//  ExploreViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit

class ExploreViewController: UIViewController {
    
    private let searchVC = UISearchController(searchResultsController: SearchResultsViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        view.backgroundColor = .systemBackground
        searchVC.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchVC
    }
}
