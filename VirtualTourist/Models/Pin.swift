//
//  Pin.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
    
    // Initializer
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude as NSNumber?
            self.longitude = longitude as NSNumber?
        }
        
        else {
            fatalError("No Entity Name Found")
        }
    }
    
    // Photos Removal
    func removePhotos(_ context: NSManagedObjectContext) {
        if let photos = photos {
            for photo in photos {
                context.delete(photo as! NSManagedObject)
            }
        }
    }
    
}
