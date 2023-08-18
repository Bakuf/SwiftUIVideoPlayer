//
//  VideoCoordinator.swift
//  SwiftUIVideoPlayer
//
//  Created by Rodrigo Galvez on 28/07/2023.
//

import Foundation

public class VideoCoordinator: ObservableObject {
    
    @Published public var state: VideoStatus = .unknown
    @Published public var volume: Double = 0.0
    @Published public var muted: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var currentTime: Double = 0.0
    @Published public var totalTime: Double = 0.0
    @Published public var currentVideo: String = ""
    @Published public var aspect: VideoAspect = .fit
    
    var playlist: PlaylistSettings = .init()
    var showLogs: Bool = false
}

extension VideoCoordinator {
    
    public static func create(video: VideoSettings, autoplay: Bool = true, showLogs: Bool = false) -> VideoCoordinator {
        let vCoord = VideoCoordinator()
        vCoord.showLogs = showLogs
        vCoord.playlist.autoplay = autoplay
        vCoord.playlist.videos.append(video)
        return vCoord
    }
    
    public static func create(playlist: [VideoSettings], autoplay: Bool = true, showLogs: Bool = false) -> VideoCoordinator {
        let vCoord = VideoCoordinator()
        vCoord.showLogs = showLogs
        vCoord.playlist.autoplay = autoplay
        vCoord.playlist.videos = playlist
        return vCoord
    }
    
}

extension VideoCoordinator {
    
    public func playVideo() {
        VideoManager.controller(for: playlist.id)?.playVideo()
    }
    
    public func pauseVideo() {
        VideoManager.controller(for: playlist.id)?.pauseVideo()
    }
    
    public func goToNextVideo() {
        VideoManager.controller(for: playlist.id)?.goToNextVideo()
    }
    
}
