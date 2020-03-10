//
//  URLComposer.swift
//  LittleWalk
//
//  Created by Scheggia on 09/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import AppFoundation

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
        components?.queryItems?.append(URLQueryItem(name: flickRadiusKey,
                                                    value: flickrRadius))
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
