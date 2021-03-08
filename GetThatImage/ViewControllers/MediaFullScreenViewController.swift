//
//  MediaFullScreenViewController.swift
//  GetThatImage
//
//  Created by Prakhar Tripathi on 08/03/21.
//

import UIKit

class MediaFullScreenViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageURL = self.imageURL {
                guard let imageData = try? Data(contentsOf: imageURL) else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imageData)
                }
            }
        }
    }
}
