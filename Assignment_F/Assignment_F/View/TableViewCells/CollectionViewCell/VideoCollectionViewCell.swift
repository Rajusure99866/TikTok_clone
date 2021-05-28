//
//  VideoCollectionViewCell.swift
//  Assignment_F
//
//  Created by Raju on 19/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieCover: UIImageView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var cellData = URL(fileURLWithPath: ""){
        didSet{
            movieCover.imageFromServerURL(cellData) { [weak self] (image, url) in
                if let self = self, let uiimage = image {
                    if (url.absoluteString == self.cellData.absoluteString) {
                        self.movieCover.image = uiimage
                        self.activityLoader.stopAnimating()
                        self.activityLoader.isHidden = true
                        self.movieCover.roundedImage()
                        self.layer.giveShadowToTableViewCell(layer: self.layer, Bounds: self.bounds, cornerRadius: 10.0)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.movieCover?.image = nil
    }
}
