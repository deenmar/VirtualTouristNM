//
//  Constants.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

extension FlickrClient {
    
    // Components
    
    struct Components {
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest"
    }
    
    // Parameter Keys
    
    struct ParameterKeys {
        static let method = "method"
        static let apiKey = "api_key"
        static let galleryID = "gallery_id"
        static let extras = "extras"
        static let format = "format"
        static let noJSONCallback = "nojsoncallback"
        static let safeSearch = "safe_search"
        static let text = "text"
        static let boundingBox = "bbox"
        static let perPage = "per_page"
        static let page = "page"
    }
    
    // Parameter Values
    
    struct ParameterValues {
        static let searchMethod = "flickr.photos.search"
        static let apiKey = "aaa5f639974e2935430fab8ebccd74d7"
        static let responseFormat = "json"
        static let disableJSONCallback = "1" /* 1 means "yes" */
        static let mediumURL = "url_m"
        static let useSafeSearch = "1" /* 1 means "yes" */
        static let defaultPerPage = 250 /* in docs, default is 250 for geo searches */
    }

    
    // JSON Response Keys
    
    struct JSONResponseKeys {
        static let status = "status"
        static let photos = "photos"
        static let photo = "photo"
        static let title = "title"
        static let mediumURL = "url_m"
        static let pages = "pages"
        static let total = "total"
    }
    
    
    // JSON Response Values
    
    struct JSONResponseValues {
        static let okStatus = "OK"
    }
    
    
    // BBox
    
    struct BBox {
        static let halfWidth = 1.0
        static let halfHeight = 1.0
        static let latRange = (-90.0, 90.0)
        static let lonRange = (-180.0, 180.0)
    }

}
