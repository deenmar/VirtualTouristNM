//
//  PhotoCoreDataProperties.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    @NSManaged var title: String?
    @NSManaged var path: String?
    @NSManaged var imageData: Data?
    @NSManaged var pin: Pin?

}
