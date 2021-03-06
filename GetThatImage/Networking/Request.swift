//
//  Request.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import Foundation

struct Request {
    let builder: RequestBuilder
    let completion: ((Result<Data, APIError>) -> Void)?
    
    init(builder: RequestBuilder, completion: ((Result<Data, APIError>) -> Void)?) {
        self.builder = builder
        self.completion = completion
    }
    
    static func get(method: HTTPMethod = .get,
                    baseURL: URL,
                    path: String? = nil,
                    params: [URLQueryItem]? = nil,
                    headers: [String: String],
                    completion: ((Result<Data, APIError>) -> Void)?) -> Request {
        let builder = GetRequestBuilder(method: method, baseURL: baseURL, path: path, params: params, headers: headers)
        return Request(builder: builder, completion: completion)
    }
    
    static func getParams() -> [URLQueryItem] {
        var params = [URLQueryItem]()
        params.append(URLQueryItem(name: "key", value: APIKey.key))
        params.append(URLQueryItem(name: "image_type", value: "photo"))
        return params
    }
}

extension Request {
    static func getImageList(completion: ((Result<ResultModel<HitsModel>, APIError>) -> Void)?) -> Request {
        Request.get(baseURL: NetworkingManager.baseURL, params: getParams(), headers: [:]) { (result) in
            result.decoding(ResultModel<HitsModel>.self, completion: completion)
        }
    }
}
