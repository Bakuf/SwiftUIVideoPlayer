//
//  VideoPlayer.swift
//
//
//  Created by Rodrigo Galvez on 24/03/22.
//

import Foundation
import AVFoundation
import UIKit

public class VideoView : UIView {
    
    override public class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    weak var playerController : VideoController?
    var dontCleanUpNextCall : Bool = false
    var videoId : String = ""
    fileprivate var cleanUpTimer: Timer?
    
    var videoSize : CGSize {
        if let videoLayer = layer as? AVPlayerLayer {
            return videoLayer.videoRect.size
        }
        return .zero
    }
    
    public override func didMoveToWindow() {
        if window == nil {
            if dontCleanUpNextCall { return }
            removeFromSuperview()
        }else{
            resetTimer()
            print("VideoView - \(videoId) is visible in window: \(String(describing: window))")
            playerController?.setPlayerItemIfNeeded()
        }
    }
    
    func configureAndSet(on view: UIView) {
        if superview != view {
            view.isUserInteractionEnabled = true
            removeFromSuperview()
            resetTimer()
            view.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: view.leadingAnchor),
                trailingAnchor.constraint(equalTo: view.trailingAnchor),
                topAnchor.constraint(equalTo: view.topAnchor),
                bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    
            if let videoLayer = layer as? AVPlayerLayer {
                videoLayer.videoGravity = .resizeAspectFill
            }
            dontCleanUpNextCall = false
        }
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        cleanUpTimer = .scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] timer in
            self?.timeToClean()
        })
    }
    
    func resetTimer() {
        cleanUpTimer?.invalidate()
        cleanUpTimer = nil
    }
    
    fileprivate func timeToClean() {
        if dontCleanUpNextCall { return }
        VideoManager.cleanUp(video: self)
    }
    
}
