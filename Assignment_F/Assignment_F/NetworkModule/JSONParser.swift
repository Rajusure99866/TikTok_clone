//
//  JSONParser.swift
//  Assignment_F
//
//  Created by Raju on 20/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import Foundation


typealias AppListResponse = (_ status: Bool, _ response: [Video]?) -> Void

class JSONParser: NSObject {

    func getInfo(_ completion: @escaping AppListResponse) {
        
        if let jsonData = self.getAppsInfo() {
            let feed = self.createCodableModel(from: jsonData, of: VideoParser.self)
            var videoModels = [Video]()
            feed?.forEach({ (VideoParser) in
                var videoUrls = [URL]()
                VideoParser.nodes?.forEach({ (dict) in
                    if let urlLink = dict["video"]?["encodeUrl"], let url = URL(string: urlLink) {
                        videoUrls.append(url)
                    }
                })
                
                videoModels.append(Video(title: VideoParser.title, videoURLs: videoUrls, currentlySelectedVideo: nil))
            })
            completion(true, videoModels)
        }
        else {
            completion(false, nil)
        }
    }
    
    func getAppsInfo() -> Data? {
        if let path = Bundle.main.path(forResource: "assignment", ofType: "json")
        {
            do {
                let url = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: url, options: .mappedIfSafe)
                return jsonData
            }
            catch  {
                print("Did not find json")
            }
        }
        
        return nil
    }
    
    func createCodableModel<T: Codable>(from json: Data, of type: T.Type) -> [VideoParser]? {
        var model: [VideoParser]?
        do {
            model = try JSONDecoder().decode(Array<VideoParser>.self, from: json)
        } catch {
            print("Could not decode object of type: \(T.self), due to an error=\(error)")
        }
        return model
    }
    
}
