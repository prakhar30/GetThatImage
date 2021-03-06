//
//  ResultModel.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import Foundation

struct ResultModel<T: Model>: Model {
    var total: Int?
    var totalHits: Int?
    var hits: T?
}

struct HitsModel: Model {
    var id: Int?
    var webformatURL: String?
    var webformatWidth: Int?
    var webformatHeight: Int?
    var views: Int?
    var downloads: Int?
}
