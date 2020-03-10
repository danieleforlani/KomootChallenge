//
//  PhotoModel.swift
//  LittleWalk
//
//  Created by Scheggia on 09/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import Foundation
import CoreData
import AppFoundation

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

extension Photo: MOTransformable {
    func managedObject(_ context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) ?? NSEntityDescription()
        let moPhoto = MOPhoto(entity: entity, insertInto: context)
        moPhoto.id = UUID().uuidString
        moPhoto.owner = owner
        moPhoto.secret = secret
        moPhoto.server = server
        moPhoto.title = title
        moPhoto.farm = NSNumber(value: farm)
        moPhoto.time = NSNumber(value: Date().timeIntervalSince1970)
        moPhoto.url = URLComposer().photoURL(farm: "\(farm)",
                                             server: server,
                                             id: id,
                                             secret: secret)
        return moPhoto
    }

    var idValue: String {
        id
    }
    var idKey: String {
        "id"
    }
}

@objc(MOPhoto)
class MOPhoto: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var owner: String?
    @NSManaged public var secret: String?
    @NSManaged public var server: String?
    @NSManaged public var title: String?
    @NSManaged public var farm: NSNumber?
    @NSManaged public var time: NSNumber?
    @NSManaged public var url: String?
}
