//
//  TestVideo.swift
//  SwiftUIVideoPlayer
//
//  Created by Rodrigo Galvez on 04/08/2023.
//

import Foundation
import SwiftUIVideoPlayer

struct TestVideo {
    let id: String
    let url: String
    let pathToSave: String?
    
    func convert() -> VideoSettings {
        .init(id: id,
              url: url,
              pathToSave: pathToSave,
              loopNumber: 0)
    }
}

extension TestVideo {
    
    struct constants {
        static let tempDirectoryFolder = "VideosTemp"
        static let documentsDirectoryFolder = "Videos"
    }
    
    static let tempDirectoryPath : String = {
        let paths = FileManager.default.urls(for: .cachesDirectory,
                                             in: .userDomainMask)
        return paths[0].appendingPathComponent(constants.tempDirectoryFolder).path
    }()
    
    static let documentsDirectoryPath : String = {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        return paths[0].appendingPathComponent(constants.documentsDirectoryFolder).path
    }()
    
    static let all: [TestVideo] = [
        .init(id: "For Bigger Fun", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", pathToSave: documentsDirectoryPath),
        .init(id: "For Bigger Blazes", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", pathToSave: documentsDirectoryPath),
        .init(id: "For Bigger Escape", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", pathToSave: documentsDirectoryPath),
        .init(id: "For Bigger Joyrides", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", pathToSave: documentsDirectoryPath),
        .init(id: "For Bigger Meltdowns", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", pathToSave: tempDirectoryPath)
    ]
    
    static let singleVideo : TestVideo = .init(id: "For Bigger Fun", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", pathToSave: documentsDirectoryPath)
    
    static func deleteVideoFolder() {
        do {
            try FileManager.default.removeItem(atPath: documentsDirectoryPath)
        } catch {
            print("There was an error deleting the video folder : \(error)")
        }
    }
    
}
