//
//  CustomPlayerItem.swift
//  Assignment_F
//
//  Created by Raju on 20/02/21.
//  Copyright © 2021 Raju. All rights reserved.
//

import Foundation
import AVFoundation

fileprivate extension URL {
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
}

@objc protocol CustomPlayerItemDelegate {
    
    @objc optional func playerItem(_ playerItem: CustomPlayerItem, didFinishDownloadingData data: Data)
    
    @objc optional func playerItem(_ playerItem: CustomPlayerItem, downloadingFailedWith error: Error)
    
    /// Is called after initial prebuffering is finished, means
    /// we are ready to play.
    @objc optional func playerItemReadyToPlay(_ playerItem: CustomPlayerItem)
}

open class CustomPlayerItem: AVPlayerItem {
    
    class ResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
        
        var playingFromData = false
        var mimeType: String? // is required when playing from Data
        var session: URLSession?
        var mediaData: Data?
        var response: URLResponse?
        var pendingRequests = Set<AVAssetResourceLoadingRequest>()
        weak var owner: CustomPlayerItem?
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            
            if playingFromData {

            } else if session == nil {
                guard let initialUrl = owner?.url else {
                    fatalError("internal inconsistency")
                }
                
                startDataRequest(with: initialUrl)
            }
            
            pendingRequests.insert(loadingRequest)
            processPendingRequests()
            
            return true
        }
        
        func startDataRequest(with url: URL) {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            session?.dataTask(with: url).resume()
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
            pendingRequests.remove(loadingRequest)
        }
        
        // MARK: URLSession delegate
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            mediaData?.append(data)
            processPendingRequests()
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(Foundation.URLSession.ResponseDisposition.allow)
            mediaData = Data()
            self.response = response
            processPendingRequests()
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let errorUnwrapped = error {
                owner?.delegate?.playerItem?(owner!, downloadingFailedWith: errorUnwrapped)
                return
            }
            processPendingRequests()
            owner?.delegate?.playerItem?(owner!, didFinishDownloadingData: mediaData!)
        }
        
        // MARK: -
        func processPendingRequests() {
            
            // get all fullfilled requests
            let requestsFulfilled = Set<AVAssetResourceLoadingRequest>(pendingRequests.compactMap {
                self.fillInContentInformationRequest($0.contentInformationRequest)
                if self.haveEnoughDataToFulfillRequest($0.dataRequest!) {
                    $0.finishLoading()
                    return $0
                }
                return nil
            })
            
            // remove fulfilled requests from pending requests
            _ = requestsFulfilled.map { self.pendingRequests.remove($0) }
            
        }
        
        func fillInContentInformationRequest(_ contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) {
            
            // if we play from Data we make no url requests, therefore we have no responses, so we need to fill in contentInformationRequest manually
            if playingFromData {
                contentInformationRequest?.contentType = self.mimeType
                contentInformationRequest?.contentLength = Int64(mediaData!.count)
                contentInformationRequest?.isByteRangeAccessSupported = true
                return
            }
            
            guard let responseUnwrapped = response else {
                // have no response from the server yet
                return
            }
            
            contentInformationRequest?.contentType = responseUnwrapped.mimeType
            contentInformationRequest?.contentLength = responseUnwrapped.expectedContentLength
            contentInformationRequest?.isByteRangeAccessSupported = true
            
        }
        
        func haveEnoughDataToFulfillRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
            
            let requestedOffset = Int(dataRequest.requestedOffset)
            let requestedLength = dataRequest.requestedLength
            let currentOffset = Int(dataRequest.currentOffset)
            
            guard let songDataUnwrapped = mediaData,
                songDataUnwrapped.count > currentOffset else {
                    // Don't have any data at all for this request.
                    return false
            }
            
            let bytesToRespond = min(songDataUnwrapped.count - currentOffset, requestedLength)
            let dataToRespond = songDataUnwrapped.subdata(in: Range(uncheckedBounds: (currentOffset, currentOffset + bytesToRespond)))
            dataRequest.respond(with: dataToRespond)
            
            return songDataUnwrapped.count >= requestedLength + requestedOffset
            
        }
        
        deinit {
            session?.invalidateAndCancel()
        }
    }
    
    fileprivate var resourceLoaderDelegate: ResourceLoaderDelegate?
    var url: URL?
    fileprivate var initialScheme: String?
    fileprivate var customFileExtension: String?
    
    weak var delegate: CustomPlayerItemDelegate?
    
    open func download() {  
        if let url = self.url, resourceLoaderDelegate?.session == nil {
            resourceLoaderDelegate?.startDataRequest(with: url)
        }
    }
    
    private let CustomPlayerItemScheme = "CustomPlayerItemScheme"
    
    /// Is used for playing remote files.
    convenience init(url: URL) {
        self.init(url: url, customFileExtension: nil)
    }

    
    convenience init(url: URL, customFileExtension: String?) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let scheme = components.scheme,
            var urlWithCustomScheme = url.withScheme("CustomPlayerItemScheme") else {
                fatalError("Urls without a scheme are not supported")
        }
        
        
        
        let asset = AVURLAsset(url: urlWithCustomScheme)
        let resourceLoaderDelegate = ResourceLoaderDelegate()
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
        self.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        self.url = url
        self.initialScheme = scheme
        self.resourceLoaderDelegate = resourceLoaderDelegate
        addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        if let ext = customFileExtension {
            urlWithCustomScheme.deletePathExtension()
            urlWithCustomScheme.appendPathExtension(ext)
            self.customFileExtension = ext
        }
        
        resourceLoaderDelegate.owner = self
    }
    
    /// Is used for playing from Data.
    convenience init(data: Data, mimeType: String, fileExtension: String) {
        
        guard let fakeUrl = URL(string: "CustomPlayerItemScheme" + "://whatever/file.\(fileExtension)") else {
            fatalError("internal inconsistency")
        }
 
        let asset = AVURLAsset(url: fakeUrl)
        let resourceLoaderDelegate = ResourceLoaderDelegate()
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
        self.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        self.url = fakeUrl
        self.initialScheme = nil
        resourceLoaderDelegate.mediaData = data
        resourceLoaderDelegate.playingFromData = true
        resourceLoaderDelegate.mimeType = mimeType
        resourceLoaderDelegate.owner = self
        self.resourceLoaderDelegate = resourceLoaderDelegate
        addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        delegate?.playerItemReadyToPlay?(self)
    }
    
    public override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }


    deinit {
        resourceLoaderDelegate?.session?.invalidateAndCancel()
    }
    
}

