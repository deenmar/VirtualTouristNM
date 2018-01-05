//
//  Photo.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    // Initializer
    
    convenience init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) else {
                fatalError("No Entity name Found")
                }
            self.init(entity: entity, insertInto: context)
            self.title = dictionary[FlickrClient.JSONResponseKeys.title] as? String
            self.path = dictionary[FlickrClient.JSONResponseKeys.mediumURL] as? String
           
    }
    
    func getImage() -> UIImage? {
            guard let imageData = imageData else {
            return nil
            }
            return UIImage(data: imageData as Data)
    }
    
    // Getting photos from arrays of dictionaries
    static func photosArrayofDictionaries(_ dictionaries: [[String: AnyObject]], context: NSManagedObjectContext) -> [Photo] {
            var photos = [Photo]()
            for photoDictionary in dictionaries {
            photos.append(Photo(dictionary: photoDictionary, context: context))
            }
            return photos
    }
}

