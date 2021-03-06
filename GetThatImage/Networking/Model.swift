//
//  Model.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import Foundation

protocol Model: Codable {
    static var decoder: JSONDecoder { get }
    static var encoder: JSONEncoder { get }
}

extension Model {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
