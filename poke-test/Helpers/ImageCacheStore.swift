//
//  ImageCacheStore.swift
//  poke-test
//
//  Created by Samantha Cruz on 24/5/23.
//

import UIKit

final class ImageCacheStore {
    
    private let placeHolder = #imageLiteral(resourceName: "PlaceHolderImage")
    private let cache = NSCache<NSString, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    static let shared = ImageCacheStore()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 52428800 // 50MB
    }
    
    func getCacheImage(for imageURL: String?) async -> UIImage {
        guard let imageURL = imageURL else {
            return placeHolder
        }
        
        if let image = cache.object(forKey: NSString(string: imageURL)) {
            return image
        } else {
            do {
                let image = try await APIManager.fetchImage(imageURL: imageURL)
                cache.setObject(image, forKey: NSString(string: imageURL))
                return image
            } catch {
                assertionFailure("Unable to fetch image from backend")
                return placeHolder
            }
        }
    }
}
