//
//  VideoView.swift
//  CrissCross
//
//  Created by Kyle Lee on 9/3/20.
//  Copyright © 2020 Kilo Loco. All rights reserved.
//

import AVKit
import UIKit
import Cache


final class VideoView: UIView {
    
    private var looper: AVPlayerLooper?
     var queuePlayer: AVQueuePlayer?
    private let playerLayer = AVPlayerLayer()
     var playerItem: CustomPlayerItem?
    var storage: Cache.Storage<String, Data>?
    var shouldStartPlaying = false
    var progressIndicator:CustomProgressIndicator?
    var observer: NSKeyValueObservation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSelf()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
         setupSelf()
    }
    
    private func setupSelf() {
        backgroundColor = .black
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        playerLayer.frame = layer.bounds
    }
    
    func prepareVideo(at url: URL, storage: Cache.Storage<String, Data>?) {
        self.storage = storage
        storage?.async.entry(forKey: url.absoluteString, completion: { [weak self] result in
            if let self = self {
                let playerItem: CustomPlayerItem
                switch result {
                case .error(_):
                    // The track is not cached.
                    playerItem = CustomPlayerItem(url: url)
                    self.startProgressIndicator()
                    playerItem.download()
                case .value(let entry):
                    // The track is cached.
                    print("Loaded from Cache###########")
                    playerItem = CustomPlayerItem(data: entry.object, mimeType: "video/mp4", fileExtension: "mp4")
                }
                
                playerItem.delegate = self
                self.queuePlayer?.removeAllItems()
                self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
                self.queuePlayer?.automaticallyWaitsToMinimizeStalling = false
                self.playerLayer.player = self.queuePlayer
                self.looper = AVPlayerLooper(player: self.queuePlayer!, templateItem: playerItem)
                
                if (self.shouldStartPlaying) {
                    self.startPlayer()
                }
            }
        })
        
        if (playerItem == nil) {
            playerItem = CustomPlayerItem(url: url)
        }
    }
    
    func stopPlayer() {
        DispatchQueue.main.async {
           self.queuePlayer?.pause()
        }
    }
    
    func startProgressIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if (self.progressIndicator == nil) {
                self.subviews.forEach({ (view) in
                    view.removeFromSuperview()
                })
                self.progressIndicator = CustomProgressIndicator()
                self.progressIndicator?.stopShowingAndDismissingAnimation = true
                self.progressIndicator?.spinnerSize = .SpinnerSizeMedium
                self.progressIndicator?.spinnerColor = UIColor.white
                self.addSubview(self.progressIndicator!)
                self.progressIndicator?.translatesAutoresizingMaskIntoConstraints = false
                self.progressIndicator?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                self.progressIndicator?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                self.progressIndicator?.startAnimating()
            }
        }
    }
    
    func stopProgressIndicator() {
        DispatchQueue.main.async {
            if let progressIndicator = self.progressIndicator {
                if (progressIndicator.isAnimating == true) {
                    progressIndicator.removeFromSuperview()
                    progressIndicator.stopAnimating()
                    self.progressIndicator = nil
                }
            }
        }
    }
    
    func startPlayer() {
        DispatchQueue.main.async {
            
            if let player = self.queuePlayer {
                player.play()
            }
            else {
                self.shouldStartPlaying = true
            }
        }
    }

    func resetPlayer() {
        playerItem = nil
        playerLayer.player = nil
        looper = nil
        self.progressIndicator = nil
    }
    
    deinit {
        self.observer?.invalidate()
    }
}

extension VideoView: CustomPlayerItemDelegate {
    func playerItem(_ playerItem: CustomPlayerItem, didFinishDownloadingData data: Data) {
        // A track is downloaded. Saving it to the cache asynchronously.
        if let url = playerItem.url {
            self.storage?.async.setObject(data, forKey: url.absoluteString, completion: { _ in
            })
            print("Finish Download#############")
        }
    }
    
    func playerItemReadyToPlay(_ playerItem: CustomPlayerItem) {
        self.stopProgressIndicator()
//        print("Player item ready to play##############")
    }
    
}
