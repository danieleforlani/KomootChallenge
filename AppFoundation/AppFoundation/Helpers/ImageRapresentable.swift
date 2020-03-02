//
//  ImageRapresentable.swift
//  MarksAndSpencer
//
//  Created by Scheggia on 13/10/2018.
//  Copyright © 2018 Scheggia. All rights reserved.
//

import Foundation
import UIKit

protocol ImageRapresentable: class {
    var image: UIImage? {get set}
    var network: NetworkingType {get}
}

extension ImageRapresentable {

    func fetchImage(path: String) {
        guard let url = URL(string: path) else { return }
        _ = network.load(URLRequest(url: url)) { [weak self] (result: Result<UIImage, ApiError>) in
            switch result {
            case .success(let image):
                self?.image = image
            case .failure:
                return
            }
        }
    }
}
