//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/05/17.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import SystemConfiguration

protocol Reachability{
}
extension NSObject: Reachability{
    
        enum ReachabilityStatus{
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus{
        
        var noAddress = sockaddr_in()
        noAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        noAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRoute = withUnsafePointer(to: &noAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1){
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else{
            return .notReachable
        }
        
        var reachabilityFlags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRoute, &reachabilityFlags) {
            return .notReachable
        }
        if reachabilityFlags.contains(.reachable) == false{
            
            return .notReachable
        }
        else if reachabilityFlags.contains(.isWWAN) == true{
            return .reachableViaWWAN
        }
        else if reachabilityFlags.contains(.connectionRequired) == false{
            return .reachableViaWiFi
        }
        else if (reachabilityFlags.contains(.connectionOnDemand) == true || reachabilityFlags.contains(.connectionOnTraffic) == true) && reachabilityFlags.contains(.interventionRequired) == false {
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
}
