//
//  NetworkingManager.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import Foundation

struct NetworkingManager {
    static let baseURL = URL(string: "https://pixabay.com/api/")!
    
    static var api: APICLient = {
        let config = URLSessionConfiguration.default
        return APICLient(config: config)
    }()
}

