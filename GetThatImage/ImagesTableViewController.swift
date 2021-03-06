//
//  ImagesTableViewController.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import UIKit
import Nuke

class ImagesTableViewController: UITableViewController {

    var photos: [HitsModel?]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
        self.getImageList()
    }
    
    func getImageList() {
        NetworkingManager.api.send(request: .getImageList(page: 1, completion: { (result) in
            switch result {
            case .success(let response):
                self.photos = response.hits
            case .failure(let error):
                print("failed to get images \(error.localizedDescription)")
            }
        }))
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.photos?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(style: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        let photoDetails = photos?[indexPath.row]
        
        cell.textLabel?.text = "\(photoDetails?.id)"
        if let url = URL(string: photoDetails?.webformatURL ?? "") {
            Nuke.loadImage(with: url, into: cell.imageView ?? UIImageView())
        }
        
//        switch (photoDetails.state) {
//        case .failed:
//            indicator.stopAnimating()
//            cell.textLabel?.text = "Failed to load"
//        case .new, .downloaded:
//            indicator.stopAnimating()
//            if !tableView.isDragging && !tableView.isDecelerating {
//                startOperations(for: photoDetails, at: indexPath)
//            }
//        }
        
        return cell
    }
}
