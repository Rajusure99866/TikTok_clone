//
//  ImageView+Entension.swift
//  Assignment_F
//
//  Created by Raju on 19/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import Foundation
import UIKit


extension UIImageView {
    
    func imageFromServerURL(_ URLString: URL, callback:@escaping ((UIImage?, URL) -> Void)) {
        ImageCacheHelper.downloadImage(url: URLString) { (uiimage, url) in
            DispatchQueue.main.async {
                if let image = uiimage {
                    callback(image, url)
                }
                else {
                    callback(nil, url)
                }
            }
        }
    }
    
    func roundedImage() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
}
