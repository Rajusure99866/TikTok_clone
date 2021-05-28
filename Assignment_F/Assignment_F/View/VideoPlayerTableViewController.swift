//
//  VideoPlayerTableViewController.swift
//  Assignment_F
//
//  Created by Raju on 24/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import UIKit
import AVKit
import Cache

class VideoPlayerTableViewController: UITableViewController {
    var playerItem: CustomPlayerItem?
    var player: AVQueuePlayer?
    var storage: Cache.Storage<String, Data>?
    var videoData = Video()
    
    fileprivate var isInitialScrollingDone = false
    @objc dynamic var currentIndex = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cell = self.tableView.visibleCells.first as? VideoPlayerTableViewCell {
            cell.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = tableView.visibleCells.first as? VideoPlayerTableViewCell {
            cell.pause()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if (!isInitialScrollingDone) {
            isInitialScrollingDone = true
            if let url = videoData.currentlySelectedVideo, let row = videoData.videoURLs?.firstIndex(of: url) {
                tableView.scrollToRow(at: IndexPath(item: row, section: 0), at: UITableView.ScrollPosition.middle, animated: false)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .black
        tableView.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
        tableView.isPagingEnabled = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        tableView.register(UINib(nibName: "VideoPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoPlayerCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension VideoPlayerTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoData.videoURLs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerTableViewCell
        if let count  = videoData.videoURLs?.count, indexPath.row < count, let currentUrl = videoData.videoURLs?[indexPath.row] {
            cell.storage = storage
            cell.configure(url: currentUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? VideoPlayerTableViewCell{
            currentIndex = indexPath.row
            cell.pause()
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Pause the video when the cell is ended displaying
        if let cell = cell as? VideoPlayerTableViewCell {
            cell.pause()
        }
    }
}

// MARK: - ScrollView Extension
extension VideoPlayerTableViewController {
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cell = tableView.cellForRow(at: IndexPath(row: self.currentIndex, section: 0)) as? VideoPlayerTableViewCell
        cell?.play()
    }
    
}

