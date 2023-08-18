//
//  VideoSettings.swift
//  SwiftUIVideoPlayer
//
//  Created by Rodrigo Galvez on 03/08/2023.
//

import Foundation

public struct VideoSettings {
    
    public init(id: String, url: String, pathToSave: String? = nil, loopNumber: Int = 0) {
        self.id = id
        self.url = url
        self.pathToSave = pathToSave
        self.loopNumber = loopNumber
    }
    
    let id : String
    let url: String
    let pathToSave: String?
    ///-1 infinite loops, independent from the playlist loop
    let loopNumber: Int
}

extension VideoSettings {
    
    var filePath : String? {
        guard let pathToSave = pathToSave else { return nil }
        return pathToSave + "/" + id + ".mp4"
    }
    
}
