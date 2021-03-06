//
//  GetRequestBuilder.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import Foundation

struct GetRequestBuilder: RequestBuilder {
    var method: HTTPMethod
    var baseURL: URL
    var path: String
    var params: [URLQueryItem]?
    var headers: [String: String] = [:]
}
