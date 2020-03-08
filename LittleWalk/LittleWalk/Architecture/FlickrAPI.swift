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
    internal var networking: NetworkingType = Networking()
    private var urlComposer = URLComposer()

    init?(container: InjectionContainer) {
        guard let networking = container.resolve(NetworkingType.self) else { return nil }
        self.networking = networking
    }

    func image(url: URL, completion: @escaping (Result<UIImage, ApiError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue

        _ = networking.load(request) { (result: Result<UIImage, ApiError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let image):
                completion(.success(image))
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

class URLComposer {
    func photoSearch(location: Location) -> URL? {
        var components = URLComponents(string: "https://api.flickr.com/services/rest")
        components?.queryItems = []
        components?.queryItems?.append(URLQueryItem(name: flickrMethodKey,
                                                    value: flickrMethod))
        components?.queryItems?.append(URLQueryItem(name: flickrAPIKey,
                                                    value: flickAPI))
        components?.queryItems?.append(URLQueryItem(name: flickrPerPageKey,
                                                    value: flickrPerPage))
        components?.queryItems?.append(URLQueryItem(name: flickrLatKey,
                                                    value: "\(location.latitude)"))
        components?.queryItems?.append(URLQueryItem(name: flickrLonKey,
                                                    value: "\(location.longitude)"))
        components?.queryItems?.append(URLQueryItem(name: flickrFormatKey,
                                                    value: flickrJson))
        components?.queryItems?.append(URLQueryItem(name: flickrNoJsonCallBackKey,
                                                    value: flickrNoJsonCallBack))
        guard let url = components?.url else {
            fatalError("Be more careful how you build the url for search")
        }
        return url
    }

    func photoURL(farm: String, server: String, id: String, secret: String) -> String {
        "https://farm"
            + farm
            + ".staticflickr.com/"
            + server
            + "/"
            + id
            + "_"
            + secret
            + ".jpg"
    }
}

struct Flickr: Codable {
    let photos: Photos
    let stat: String
}
extension Flickr: DataBuildable {
    static func build(from data: Data) -> Flickr? {
       try? JSONDecoder().decode(Flickr.self, from: data)
    }
}

struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
}

import CoreData

extension Photo: MOTransformable {
    func managedObject(_ context: NSManagedObjectContext) -> NSManagedObject {
        let moPhoto = MOPHoto(context: context)
        moPhoto.id = id
        moPhoto.owner = owner
        moPhoto.secret = secret
        moPhoto.server = server
        moPhoto.title = title
        moPhoto.farm = NSNumber(value: farm)

        return moPhoto
    }

    var idValue: String {
        id
    }
    var idKey: String {
        "id"
    }
}

class MOPHoto: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var owner: String?
    @NSManaged public var secret: String?
    @NSManaged public var server: String?
    @NSManaged public var title: String?
    @NSManaged public var farm: NSNumber?
}

