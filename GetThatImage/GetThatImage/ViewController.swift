//
//  ViewController.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 06/03/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getImageList()
    }
    
    func getImageList() {
        NetworkingManager.api.send(request: .getImageList(page: 1, completion: { (result) in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print("failed to get images \(error.localizedDescription)")
            }
        }))
    }
}
