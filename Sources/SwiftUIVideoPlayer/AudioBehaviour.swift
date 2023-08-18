//
//  AudioBehaviour.swift
//
//  Created by Rodrigo Galvez on 26/03/22.
//

import Foundation
import AVFoundation

enum AudioBehaviour {
    
    enum Option {
        case mixOthers
        case duckOthers
        
        func getCategoryOption() -> AVAudioSession.CategoryOptions {
            switch self {
            case .mixOthers:
                return .mixWithOthers
            case .duckOthers:
                return .duckOthers
            }
        }
    }
    
    case ignoreSilentMode(_ option: Option)
    case respectsSilentMode(_ option: Option)
    case respectsSilentModeStopOthers
    
    func apply() {
        var mode : AVAudioSession.Mode = .default
        var category : AVAudioSession.Category = .soloAmbient //default by apple
        var option : AVAudioSession.CategoryOptions = .mixWithOthers
        switch self {
        case .ignoreSilentMode(let opt):
            mode = .moviePlayback
            category = .playback
            option = opt.getCategoryOption()
        case .respectsSilentMode(let opt):
            category = .ambient
            option = opt.getCategoryOption()
        case .respectsSilentModeStopOthers:
            category = .soloAmbient
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(category, mode: mode, options: option)
        } catch {
            print(error.localizedDescription)
        }
    }
}
