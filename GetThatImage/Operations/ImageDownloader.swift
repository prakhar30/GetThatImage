//
//  ImageDownloader.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 07/03/21.
//

import Foundation
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case new, downloaded, failed
}

class PhotoRecord {
    let name: String
    let previewURL: URL
    var webURL: URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")
    
    init(name: String, previewURL: URL, webURL: URL) {
        self.name = name
        self.previewURL = previewURL
        self.webURL = webURL
    }
}

class PreviewImageDownloader: Operation {
    let photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if isCancelled { return }
        
        guard let imageData = try? Data(contentsOf: photoRecord.previewURL) else { return }
        
        if isCancelled { return }
        
        if !imageData.isEmpty {
            photoRecord.image = UIImage(data: imageData)
            photoRecord.state = .downloaded
        } else {
            photoRecord.state = .failed
            photoRecord.image = UIImage(named: "Failed")
        }
    }
}
