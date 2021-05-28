//
//  ExploreTableViewCell.swift
//  Assignment_F
//
//  Created by Raju on 19/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import UIKit

protocol SelectedVideoDelegate: class {
    func didSelectVideo(Video:Video)
}

class ExploreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    weak var VideoDelegate:SelectedVideoDelegate!
    
    var videos = Video(){
        didSet{
            videoCollectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")
            videoCollectionView.reloadData()
        }
    }
}

extension ExploreTableViewCell:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.videoURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCollectionViewCell
        cell.activityLoader.startAnimating()
        if let videoUrls = videos.videoURLs {
            
            cell.cellData = videoUrls[indexPath.row]
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
}

extension ExploreTableViewCell:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let videosCount = videos.videoURLs?.count, (indexPath.row < videosCount) {
            if let currentUrl = videos.videoURLs?[indexPath.row] {
                self.videos.currentlySelectedVideo = currentUrl
                self.VideoDelegate?.didSelectVideo(Video: videos)
            }
        }
    }
}
