//
//  VideoPlayerTableViewCell.swift
//  Assignment_F
//
//  Created by Raju on 24/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import UIKit
import Cache

class VideoPlayerTableViewCell: UITableViewCell {

    var storage: Cache.Storage<String, Data>?

    @IBOutlet weak var playerView: VideoView!
    // MARK: - Variables
    private(set) var isPlaying = false
    
    
    // MARK: LIfecycles
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.resetPlayer()
    }
    
    func play() {
        if !isPlaying {
            playerView.startPlayer()
            isPlaying = true
        }
    }
    
    func pause(){
        if isPlaying {
            playerView.stopPlayer()
            isPlaying = false
        }
    }
    
    func resetPlayer() {
        if let playerView = self.playerView {
            playerView.resetPlayer()
        }
    }
    
    func configure(url: URL?){
        guard let url = url else {
            return
        }
        playerView.prepareVideo(at: url,storage: storage)
    }
    
}
