//
//  VideoDataModel.swift
//  Assignment_F
//
//  Created by Raju on 19/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//


import Foundation

struct FeedModel {
    let entry: [Video]
}


struct Video {
    var title:String?
    var videoURLs:[URL]?
    var currentlySelectedVideo:URL? = nil
}

struct VideoParser: Codable {
    var title:String?
    var nodes:[[String: [String: String]]]?
}


extension VideoParser {
    enum CodingKeys: String, CodingKey {
        case title
        case nodes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        var payloadsContainer = try container.nestedUnkeyedContainer(forKey: .nodes)
        var payloads = [[String: [String: String]]]()
        while !payloadsContainer.isAtEnd {
            let payloadName = try payloadsContainer.decode(Dictionary<String, Dictionary<String,String>>.self)
            payloads.append(payloadName)
        }
        
        self.nodes = payloads
    }
}
