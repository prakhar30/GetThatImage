//
//  ImagesTableViewController.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import UIKit

class ImagesTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var viewModel = ImagesTableViewModel()
    var searchTask: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
        self.tableView.prefetchDataSource = self
        self.tableView.estimatedRowHeight = 80.0
        self.setupSearchBar()
        viewModel.delegate = self
        viewModel.getImageList(searchKey: nil)
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Images"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // TODO: Add history of searches to these scopeButtonTitles and then handle their selection in selectedScopeButtonIndexDidChange
        searchController.searchBar.scopeButtonTitles = []
        searchController.searchBar.delegate = self
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.viewModel.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.viewModel.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fullScreenVC = self.viewModel.getFullScreenVC(at: indexPath)
        self.navigationController?.pushViewController(fullScreenVC, animated: true)
    }
    
    // MARK: - Scrollview delegate methods
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.viewModel.suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.viewModel.loadImagesForOnscreenCells(tableView: self.tableView)
            self.viewModel.resumeAllOperations()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.viewModel.loadImagesForOnscreenCells(tableView: self.tableView)
        self.viewModel.resumeAllOperations()
    }    
}

extension ImagesTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.getImageList(searchKey: nil)
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.photos.count
    }
}

extension ImagesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchTask?.cancel()
        // Replace previous task with a new one
        let task = DispatchWorkItem { [weak self] in
            let searchBarText = searchController.searchBar.text
            if let searchText = searchBarText, searchText != "" {
                print("searching", searchText)
            } else {
                print("default should be displayed")
            }
        }
        self.searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.00, execute: task)
    }
}

extension ImagesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // TODO: handle selection of the history of searches
    }
}

extension ImagesTableViewController: ImagesViewModelDelegate {
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func reloadTableViewRows(atIndexPaths: [IndexPath], withAnimation: UITableView.RowAnimation) {
        self.tableView.reloadRows(at: atIndexPaths, with: withAnimation)
    }
    
    func onFetchCompleted(newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else { return }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
