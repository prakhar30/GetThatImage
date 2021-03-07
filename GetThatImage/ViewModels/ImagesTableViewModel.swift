//
//  ImagesTableViewModel.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 07/03/21.
//

import Foundation
import UIKit
import Nuke
protocol ImagesViewModelDelegate: class {
    func reloadTableView()
    func reloadTableViewRows(atIndexPaths: [IndexPath], withAnimation: UITableView.RowAnimation)
}

class ImagesTableViewModel {
    var photos: [PhotoRecord] = []
    let pendingOperations = PendingOperations()
    weak var delegate: ImagesViewModelDelegate?
    
    func getImageList() {
        NetworkingManager.api.send(request: .getImageList(page: 1, completion: { (result) in
            switch result {
            case .success(let response):
                for hit in response.hits {
                    if let url = URL(string: hit?.webformatURL ?? "") {
                        self.photos.append(PhotoRecord(name: "\(hit?.id ?? 0)", url: url))
                    }
                }
                DispatchQueue.main.async {
                    self.delegate?.reloadTableView()
                }
            case .failure(let error):
                print("failed to get images \(error.localizedDescription)")
            }
        }))
    }
    
    // MARK: TableView Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(style: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        let photoDetails = self.photos[indexPath.row]
        
        cell.textLabel?.text = photoDetails.name
        Nuke.loadImage(with: photoDetails.url, into: cell.imageView ?? UIImageView())
        
        switch (photoDetails.state) {
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .new, .downloaded:
            indicator.stopAnimating()
            if !tableView.isDragging && !tableView.isDecelerating {
                startOperations(for: photoDetails, at: indexPath)
            }
        }
        
        return cell
    }
    
    // MARK: - operation management
    func suspendAllOperations() {
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells(tableView: UITableView) {
        if let pathsArray = tableView.indexPathsForVisibleRows {
            let allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = self.pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                let recordToProcess = self.photos[indexPath.row]
                startOperations(for: recordToProcess, at: indexPath)
            }
        }
    }
    
    func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        switch (photoRecord.state) {
        case .new:
            startDownload(for: photoRecord, at: indexPath)
        case .downloaded:
            DispatchQueue.main.async {
                self.delegate?.reloadTableViewRows(atIndexPaths: [indexPath], withAnimation: .none)
            }
        default:
            print("do nothing")
        }
    }
    
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        guard self.pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        
        let downloader = ImageDownloader(photoRecord)
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.delegate?.reloadTableViewRows(atIndexPaths: [indexPath], withAnimation: .fade)
            }
        }
        self.pendingOperations.downloadsInProgress[indexPath] = downloader
        self.pendingOperations.downloadQueue.addOperation(downloader)
    }
}
