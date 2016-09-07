//
//  MyImageCache.swift
//  FirebaseChat
//
//  Created by Safina Lifa on 9/6/16.
//  Copyright © 2016 Safina Lifa. All rights reserved.
//

import Foundation

class MyImageCache {
    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "MyImageCache"
        cache.countLimit = 200 // Max 200 images in memory 
        cache.totalCostLimit = 20*1024*1024 // Max 20MB used 
        return cache
    }() 
}
