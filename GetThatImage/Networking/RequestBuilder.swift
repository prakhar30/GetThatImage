//
//  RequestBuilder.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import Foundation

protocol RequestBuilder {
    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var params: [URLQueryItem]? { get }
    var headers: [String: String] { get }
    
    func toURLRequest() -> URLRequest
    func encodeRequestBody() -> Data?
}

extension RequestBuilder {
    func toURLRequest() -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = params
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue.uppercased()
        request.httpBody = encodeRequestBody()
        return request
    }
    
    func encodeRequestBody() -> Data? {
        return nil
    }
}
