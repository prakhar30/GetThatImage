//
//  ImagesTableViewModel.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 07/03/21.
//

import Foundation
import UIKit

protocol ImagesViewModelDelegate: class {
    func reloadTableView()
    func reloadTableViewRows(atIndexPaths: [IndexPath], withAnimation: UITableView.RowAnimation)
    func onFetchCompleted(newIndexPathsToReload: [IndexPath]?)
}

class ImagesTableViewModel {
    private var isFetchInProgress = false
    var photos: [PhotoRecord] = []
    let pendingOperations = PendingOperations()
    var currentPage = 1
    var total = 0
    weak var delegate: ImagesViewModelDelegate?
    
    func getImageList() {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        NetworkingManager.api.send(request: .getImageList(page: currentPage, completion: { (result) in
            switch result {
            case .success(let response):
                self.total = response.totalHits ?? 0
                var tempPhotos: [PhotoRecord] = []
                for hit in response.hits {
                    if let previewURL = URL(string: hit?.previewURL ?? ""), let fullURL = URL(string: hit?.webformatURL ?? "") {
                        tempPhotos.append(PhotoRecord(name: "\(hit?.id ?? 0)", previewURL: previewURL, webURL: fullURL))
                    }
                }
                self.photos.append(contentsOf: tempPhotos)
                DispatchQueue.main.async {
                    if self.currentPage > 1 {
                        // reload only the news rows added as a result of fetching the new page
                        let indexPathsToReload = self.calculateIndexPathsToReload(newPhotos: tempPhotos)
                        self.delegate?.onFetchCompleted(newIndexPathsToReload: indexPathsToReload)
                    } else {
                        // normally reload tableview as this is the first page fetched.
                        self.delegate?.reloadTableView()
                    }
                    self.currentPage += 1
                    self.isFetchInProgress = false
                }
            case .failure(let error):
                self.isFetchInProgress = false
                print("failed to get images \(error.localizedDescription)")
            }
        }))
    }
    
    func calculateIndexPathsToReload(newPhotos: [PhotoRecord]) -> [IndexPath] {
        let startIndex = self.photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func getFullScreenVC(at indexPath: IndexPath) -> MediaFullScreenViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MediaFullScreenViewController_ID") as! MediaFullScreenViewController
        vc.imageURL = photos[indexPath.row].webURL
        return vc
    }
    
    // MARK: TableView Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.total
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
        cell.imageView?.image = photoDetails.image
        cell.imageView?.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        cell.imageView?.contentMode = .scaleAspectFit
        
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
        
        let downloader = PreviewImageDownloader(photoRecord)
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
