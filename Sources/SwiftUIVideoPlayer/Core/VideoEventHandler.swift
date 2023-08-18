//
//  VideoEventHandler.swift
//
//  Created by Rodrigo Galvez on 26/03/22.
//

import Foundation
import AVFoundation

public enum VideoStatus : String {
    case buffering
    case playing
    case paused
    case stoped
    case reachedEnd
    case unknown
}

protocol VideoEventHandlerDelegate {
    func VideoStatusChanged(status: VideoStatus)
}

class VideoEventHandler : NSObject {
    
    var currentVideoStatus : VideoStatus {
        didSet {
            delegate?.VideoStatusChanged(status: currentVideoStatus)
        }
    }
    
    weak var player : AVPlayer?
    weak var playerItem : AVPlayerItem?
    var delegate : VideoEventHandlerDelegate?
    var debugPrint = false
    
    internal init(player: AVPlayer, playerItem: AVPlayerItem, delegate: VideoEventHandlerDelegate) {
        self.player = player
        self.playerItem = playerItem
        self.delegate = delegate
        self.currentVideoStatus = .unknown
        super.init()
        startObserving(player: player)
        startObserving(item: playerItem)
    }
    
    //
    //MARK - Observer Methods
    //
    func removeObservers(){
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func startObserving(player: AVPlayer) {
        self.player = player
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    fileprivate func startObserving(item: AVPlayerItem){
        playerItem = item
        NotificationCenter.default.addObserver(self, selector: #selector(handleEvent), name: .AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEvent), name: .AVPlayerItemPlaybackStalled, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEvent), name: .AVPlayerItemNewAccessLogEntry, object: item)
    }
    
    //
    //MARK - Observer Callback Methods
    //
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                switch newStatus {
                case .paused:
                    currentVideoStatus = .paused
                case .waitingToPlayAtSpecifiedRate:
                    currentVideoStatus = .buffering
                case .playing:
                    currentVideoStatus = .playing
                case .none:
                    currentVideoStatus = .unknown
                case .some(_):
                    currentVideoStatus = .unknown
                }
            }
        }
    }
    
    @objc func handleEvent(notification: NSNotification) {
        guard let playerItem = playerItem, let notifItem = notification.object as? AVPlayerItem, playerItem == notifItem else {
            return
        }
        if notification.name == .AVPlayerItemDidPlayToEndTime {
            currentVideoStatus = .reachedEnd
        }
        if notification.name == .AVPlayerItemPlaybackStalled {
            currentVideoStatus = .buffering
        }
        if notification.name == .AVPlayerItemNewAccessLogEntry {
            if debugPrint { print("New access log for video, status : \(playerItem.status)") }
        }
        if debugPrint { print(notification) }
    }
    
}
