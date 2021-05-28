//
//  ImageCacheHelper.swift
//  Assignment_F
//
//  Created by Raju on 20/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import Foundation
import UIKit
import AVKit

fileprivate let imageCache = NSCache<NSString, UIImage>()

extension NSError {
    static func generalParsingError(domain: String) -> Error {
        return NSError(domain: domain, code: 400, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Error retrieving data", comment: "General Parsing Error Description")])
    }
}

class ImageCacheHelper {
    static func downloadImage(url: URL, completion: @escaping (_ image: UIImage?, _ url: URL) -> Void) {
        let bgQueue = DispatchQueue(label: "com.task.MacAppStore.imageDownloader")
        bgQueue.async {
            if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
                completion(cachedImage, url)
            } else {
                let asset = AVURLAsset(url: url)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                do{
                     let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let uiImage = UIImage(cgImage: cgImage)
                    imageCache.setObject(uiImage, forKey: url.absoluteString as NSString)
                    completion(uiImage, url)
                }
                catch {
                    completion(nil, url)
                }
            }
        }
    }
}

