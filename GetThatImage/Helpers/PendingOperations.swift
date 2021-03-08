//
//  PendingOperations.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 07/03/21.
//

import Foundation

class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.prakhar.getThatImage.downloadQueue"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
}
