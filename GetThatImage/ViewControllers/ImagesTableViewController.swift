//
//  ImagesTableViewController.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import UIKit
import Nuke

class ImagesTableViewController: UITableViewController {
    var viewModel = ImagesTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
        viewModel.delegate = self
        viewModel.getImageList()
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

extension ImagesTableViewController: ImagesViewModelDelegate {
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func reloadTableViewRows(atIndexPaths: [IndexPath], withAnimation: UITableView.RowAnimation) {
        self.tableView.reloadRows(at: atIndexPaths, with: withAnimation)
    }
}
