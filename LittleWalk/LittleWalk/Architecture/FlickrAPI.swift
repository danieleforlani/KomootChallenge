//
//  FlickrAPI.swift
//  LittleWalk
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import Foundation
import AppFoundation
import UIKit

protocol FlickrAPIType {
    var networking: NetworkingType { get }
    func image(url: URL, completion: @escaping (Result<UIImage, ApiError>) -> Void)
    func photoSearch(location: Location,
                       completion: @escaping (Result<Flickr, ApiError>) -> Void)
}

class FlickrAPI: FlickrAPIType {
    internal var networking: NetworkingType
    private var urlComposer = URLComposer()

    init(networking: NetworkingType = Networking()) {
        self.networking = networking
    }

    func image(url: URL, completion: @escaping (Result<UIImage, ApiError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue

        _ = networking.load(request) { (result: Result<Data, ApiError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                completion(.success(UIImage(data: data) ?? UIImage()))
            }
        }
    }

    func photoSearch(location: Location,
                       completion: @escaping (Result<Flickr, ApiError>) -> Void) {
        guard let url = URLComposer().photoSearch(location: location) else {
             completion(.failure(urlComposerError))
            return
        }
        let request = URLRequest(url: url)
        _ = networking.load(request) { (result: Result<Flickr, ApiError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                completion(.success(response))
            }
        }
    }
}


