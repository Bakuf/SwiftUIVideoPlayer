//
//  PlaylistSettings.swift
//  SwiftUIVideoPlayer
//
//  Created by Rodrigo Galvez on 03/08/2023.
//

import Foundation

public struct PlaylistSettings {
    
    public init(loopNumber: Int = 0, autoplay: Bool = true, videos: [VideoSettings] = []) {
        self.loopNumber = loopNumber
        self.autoplay = autoplay
        self.videos = videos
    }
    
    let id : String = UUID().uuidString
    ///-1 infinite loops
    var loopNumber: Int = 0
    var autoplay: Bool = true
    var videos: [VideoSettings] = []
}
