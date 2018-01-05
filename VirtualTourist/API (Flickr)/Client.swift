//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import CoreData

class FlickrClient {
    
    // HTTP
enum HTTPMethod: String {
     case GET, POST, PUT, DELETE
}
    
    // Bbox
    fileprivate func bboxString(_ latitude: Double, longitude: Double) -> String {
            let minimumLatitude = max(latitude - BBox.halfHeight, BBox.latRange.0)
            let minimumLongitude = max(longitude - BBox.halfWidth, BBox.lonRange.0)
            let maximumLatitude = min(latitude + BBox.halfHeight, BBox.latRange.1)
            let maximumLongitude = min(longitude + BBox.halfWidth, BBox.lonRange.1)
            return "\(minimumLongitude),\(minimumLatitude),\(maximumLongitude),\(maximumLatitude)"
    }
    
    // MARK: Flickr request
    
    fileprivate func flickrRequest(url: URL, method: HTTPMethod, body: [String:AnyObject]? = nil, responseHandler: @escaping (_ jsonAsDictionary: [String:AnyObject]?, _ error: NSError?) -> Void) {
        urlRequest(url, method: method, headers: nil, body: nil) {
        (data, error) in
            
        if let data = data {
           let jsonDictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        if let _ = jsonDictionary[JSONResponseKeys.status] as? String {
            responseHandler(nil, error)
        }
        
        else {
            responseHandler(jsonDictionary, nil)
            }
        }
        
        else {
            responseHandler(nil, error)
            }
        }
    }
    
    // MARK: Retrieving pages
    
    func pagesForSearch(_ searchURL: URL, completionHandler: @escaping (_ pages: Int, _ error: NSError?) -> Void) {
            flickrRequest(url: searchURL, method: .GET) { (jsonAsDictionary, error) in
            guard error == nil else {
            completionHandler(0, error)
            return
        }
        if let jsonAsDictionary = jsonAsDictionary,
            let photosDictionary = jsonAsDictionary[JSONResponseKeys.photos] as? [String:AnyObject], let totalPages = photosDictionary[JSONResponseKeys.pages] as? Int {
            completionHandler(totalPages, nil)
            return
            }
        }
    }
    
    // MARK: - Requests
    
    fileprivate func urlRequest(_ url: URL, method: HTTPMethod, headers: [String:String]? = nil, body: [String:AnyObject]? = nil, completionHandler: @escaping (Data?, NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        }
        
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
            
            (data, response, error) in
            guard error == nil else {
            return completionHandler(nil, error as NSError?)
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            return completionHandler(nil, error as NSError?)
            }
            
            completionHandler(data, nil)
        }
            task.resume()
    }
    
    // MARK: Obtaining Location of Photos
    func photosLocationsPinned(_ pin: Pin, context: NSManagedObjectContext, completionHandler: @escaping (_ photos: [Photo]?, _ error: NSError?) -> Void) {
        
        
            // Parameters
            var parameters: [String:AnyObject] = [
            ParameterKeys.method: ParameterValues.searchMethod as AnyObject,
            ParameterKeys.apiKey: ParameterValues.apiKey as AnyObject,
            ParameterKeys.boundingBox: bboxString(Double(truncating: pin.latitude!), longitude: Double(truncating: pin.longitude!)) as AnyObject,
            ParameterKeys.format: ParameterValues.responseFormat as AnyObject,
            ParameterKeys.noJSONCallback: ParameterValues.disableJSONCallback as AnyObject,
            ParameterKeys.extras: ParameterValues.mediumURL as AnyObject,
            ParameterKeys.perPage: ParameterValues.defaultPerPage as AnyObject,
            ParameterKeys.safeSearch: ParameterValues.useSafeSearch as AnyObject]
        
        
        // Photo Search
        let photoSearchURL = urlComponents(nil, parameters: parameters)
        
        pagesForSearch(photoSearchURL) {
            (pages, error) in
            
            guard error == nil else {
            completionHandler(nil, error)
            return
            }
            parameters[ParameterKeys.page] = Int(arc4random_uniform(UInt32(pages)) + 1) as AnyObject?
            let urlPageSearch = self.urlComponents(nil, parameters: parameters)
            self.flickrRequest(url: urlPageSearch, method: .GET) {
                (jsonAsDictionary, error) in
                
            guard error == nil else {
            completionHandler(nil, error)
            return
            }
                
        if let jsonAsDictionary = jsonAsDictionary, let photosDictionary = jsonAsDictionary[JSONResponseKeys.photos] as? [String:AnyObject], let photoArrayOfDictionaries = photosDictionary[JSONResponseKeys.photo] as? [[String:AnyObject]] {
            let albumSize = 20
        if photoArrayOfDictionaries.count >= albumSize {
            let startIndex = Int(arc4random_uniform(UInt32(photoArrayOfDictionaries.count - albumSize)))
            let sliceOfArrayOfDictionaries = Array(photoArrayOfDictionaries[startIndex..<startIndex + albumSize])
            completionHandler(Photo.photosArrayofDictionaries(sliceOfArrayOfDictionaries, context: context), nil)
            }
        else {
            completionHandler(Photo.photosArrayofDictionaries(photoArrayOfDictionaries, context: context), nil)
            }
            return
            }
            completionHandler(nil, error)
            }
        }
    }
    
    // MARK: URL Components
    
    fileprivate func urlComponents(_ method: String?, withPathExtension: String? = nil, parameters: [String: AnyObject]? = nil) -> URL {
        
            var components = URLComponents()
            components.scheme = Components.scheme
            components.host = Components.host
            components.path = Components.path + (method ?? "") + (withPathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
            }
        }
            return components.url!
    }
    
    // Image Data
    
    func imageData(_ photo: Photo, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) {
            let url = URL(string: photo.path!)!
            urlRequest(url, method: .GET) {
            (data, error) in
            
            guard error == nil else {
            completionHandler(nil, error)
            return
            }
            completionHandler(data, nil)
        }
    }
    
class func sharedInstance() -> FlickrClient {
        
    struct Singleton {
            static let sharedInstance = FlickrClient()
    }
            return Singleton.sharedInstance
}
}
