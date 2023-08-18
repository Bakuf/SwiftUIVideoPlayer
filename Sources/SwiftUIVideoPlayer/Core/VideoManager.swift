//
//  VideoManager.swift
//
//
//  Created by Rodrigo Galvez on 10/07/22.
//

import Foundation

class VideoManager {
    static let shared = VideoManager()
    
    var isMuted = true {
        didSet {
            for key in VideoManager.shared.videos.keys {
                if let videoController = VideoManager.shared.videos[key] {
                    videoController.muted = isMuted
                }
            }
        }
    }
    
    fileprivate var videos : [String: VideoController] = [:]
    
}

//MARK: - Public Methods
extension VideoManager {
    
    class func createVideo(coordinator: VideoCoordinator) -> VideoView {
        if let videoController = VideoManager.shared.videos[coordinator.playlist.id] {
            if videoController.coordinator?.playlist.id == coordinator.playlist.id {
                return videoController.videoView
            }else{
                fatalError("What are you trying to do man!?")
            }
        }else{
            cleanIfNeeded()
            let newVideoContoller = VideoController(coordinator: coordinator)
            VideoManager.shared.videos[coordinator.playlist.id] = newVideoContoller
            print("VideoController count \(VideoManager.shared.videos.keys.count)")
            return newVideoContoller.videoView
        }
    }
    
    class func omitNextCleanUpCall() {
        VideoManager.shared.videos.forEach { entry in
            entry.value.videoView.dontCleanUpNextCall = true
        }
    }
    
    class func cleanIfNeeded() {
        var keysToRemove : [String] = []
        VideoManager.shared.videos.forEach { entry in
            if entry.value.videoView.superview == nil {
                keysToRemove.append(entry.key)
            }
        }
        for key in keysToRemove {
            if let video = VideoManager.getVideoView(for: key) {
                VideoManager.cleanUp(video: video)
            }
        }
    }
    
    class func getVideoView(for identifier: String) -> VideoView? {
        if let videoController = VideoManager.shared.videos[identifier] {
            return videoController.videoView
        }
        return nil
    }
    
    class func controller(for identifier: String) -> VideoController? {
        return VideoManager.shared.videos[identifier]
    }
    
    class func pauseAllVideos() {
        for key in VideoManager.shared.videos.keys {
            if let videoController = VideoManager.shared.videos[key] {
                videoController.pauseVideo()
            }
        }
    }
    
    class func cleanUp(video: VideoView) {
        print("Will remove video(\(video.videoId))")
        video.playerController?.cleanUp()
        VideoManager.shared.videos.removeValue(forKey: video.videoId)
        print("Total video count after remove : \(VideoManager.shared.videos.keys.count)")
    }
    
}
