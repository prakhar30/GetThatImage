//
//  APIClient.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import Foundation

struct APICLient {
    private let session: URLSession
    private let queue: DispatchQueue
    
    init(config: URLSessionConfiguration) {
        self.session = URLSession(configuration: config)
        self.queue = DispatchQueue(label: "com.prakhar.GetThatImage.networking", qos: .userInitiated, attributes: .concurrent)
    }
    
    func send(request: Request) {
        queue.async {
            let urlRequest = request.builder.toURLRequest()
            debugPrint("request ", urlRequest)
            debugPrint("headers ", urlRequest.allHTTPHeaderFields)
            if let data = urlRequest.httpBody {
                debugPrint("body ", String(data: data, encoding: .utf8))
            }
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<Data, APIError>
                
                print("data", data?.prettyPrintedJSONString)
                if let error = error {
                    result = .failure(.networkError(error))
                } else if let apiError = APIError.error(response: response) {
                    result = .failure(apiError)
                } else {
                    result = .success(data ?? Data())
                }
                
                DispatchQueue.main.async {
                    request.completion?(result)
                }
            }
            task.resume()
        }
    }
}

// TODO: remove
extension Data {
    var prettyPrintedJSONString: NSString? {
        // NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
