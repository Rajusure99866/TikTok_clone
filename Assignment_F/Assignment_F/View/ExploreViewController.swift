//
//  ExploreViewController.swift
//  Assignment_F
//
//  Created by Raju on 19/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import UIKit
import AVKit

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var videosList: UITableView!
    var viewModel = VideosViewModel()
    var videos = [Video]()
    var selectedVideo = Video()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videosList.register(UINib(nibName: "ExploreTableViewCell", bundle: nil), forCellReuseIdentifier: "ExploreTableViewCell")
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if videos.count == 0 {
            getAllData()
        }
    }
    
    func getAllData(){
        videos.removeAll()
        viewModel.getVideosList()
    }
}

extension ExploreViewController: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 200
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 12, width: headerView.frame.width, height: headerView.frame.height-8)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        label.textColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
        headerView.backgroundColor = .white
        label.text = videos[section].title ?? ""
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTableViewCell", for: indexPath) as! ExploreTableViewCell
        cell.videos = videos[indexPath.section]
        cell.VideoDelegate = self
        return cell
    }
}

extension ExploreViewController:ViewModelDelegate{
    func reloadTable(VideoArr movieArr: [Video]) {
        videos.append(contentsOf: movieArr)
        videosList.reloadData()
    }
}

extension ExploreViewController: SelectedVideoDelegate{
    func didSelectVideo(Video: Video) {
        selectedVideo = Video
        self.performSegue(withIdentifier: "videoPlayerView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "videoPlayerView"{
            let controller = segue.destination as! VideoPlayerTableViewController
            controller.storage = self.viewModel.getCommonStorageForVideos()
            controller.videoData = selectedVideo
        }
    }
}


