//
//  VideoViewModel.swift
//  Assignment_F
//
//  Created by Raju on 19/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import Foundation
import Cache

protocol ViewModelDelegate: class {
    func reloadTable(VideoArr:[Video])
}

class VideosViewModel {
    private let diskConfig = DiskConfig(name: "DiskCache1")
    private let memoryConfig = MemoryConfig(expiry: .seconds(1800), countLimit: 10, totalCostLimit: 10)
    
    private lazy var storage: Cache.Storage<String, Data>? = {
        return try? Cache.Storage<String, Data>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    
    var Videos = [Video]()
    private let networking: JSONParser = JSONParser()
     weak var delegate: ViewModelDelegate?
    
    func getVideosList()  {
        networking.getInfo { [weak self] (isDone, feedData) in
            if isDone {
                if let data = feedData {
                    self?.Videos = data
                    self?.delegate?.reloadTable(VideoArr: data)
                }
            }
        }
    }
    
    func getCommonStorageForVideos() -> Cache.Storage<String, Data>? {
        return self.storage
    }
}

