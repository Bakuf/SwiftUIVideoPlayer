//
//  VideoController.swift
//
//
//  Created by Rodrigo Galvez on 26/03/22.
//

import Foundation
import AVFoundation
import Combine

public class VideoController {
    
    weak var coordinator: VideoCoordinator?
    var videoView: VideoView
    
    fileprivate var player : AVPlayer
    fileprivate var playerItem : CachingPlayerItem? {
        didSet {
            playerItem?.delegate = self
        }
    } //AVPlayerItem?
    fileprivate var eventHandler : VideoEventHandler?
    fileprivate var isSavingVideo : Bool = false
    fileprivate var timeObserver : Any?
    fileprivate var didReachEnd = false
    
    fileprivate var overrideStartTime : CGFloat?
    fileprivate var overrideEndTime : CGFloat?
    
    private var cancellables = Set<AnyCancellable>()
    private var progressSetByUpdate = false
    private var mutedSetByUpdate = false
    
    private let queue = DispatchQueue(label: "LocalVideoDataStore", qos: .userInitiated, attributes: .concurrent)
    
    private var videoIndex : Int = 0
    
    fileprivate var settings: VideoSettings? {
        guard (coordinator?.playlist.videos.count ?? 0) > videoIndex else {return nil}
        return coordinator?.playlist.videos[videoIndex]
    }
    
    var currentLoop : Int = 0 {
        didSet {
            debugPrint("Video loop : \(currentLoop)")
        }
    }
    
    var muted : Bool {
        get {
            player.isMuted
        }
        set {
            mutedSetByUpdate = true
            player.isMuted = newValue
            coordinator?.muted = newValue
            if !newValue && coordinator?.state == .playing {
                AudioBehaviour.ignoreSilentMode(.duckOthers).apply()
            }else{
                AudioBehaviour.ignoreSilentMode(.mixOthers).apply()
            }
        }
    }
    
    var progress : Double = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    internal init(coordinator: VideoCoordinator) {
        self.coordinator = coordinator
        let player = AVPlayer()
        self.player = player
        let videoView = VideoView(frame: .zero)
        videoView.backgroundColor = .black
        videoView.videoId = coordinator.playlist.id
        defer {
            videoView.playerController = self
        }
        self.videoView = videoView
        assingPlayer()
        self.muted = VideoManager.shared.isMuted
        subscribe()
    }
    
    fileprivate func subscribe() {
        coordinator?.$progress
            .sink(receiveValue: { [weak self] value in
                self?.sliderChanged(percent: value)
            })
            .store(in: &cancellables)
        
        coordinator?.$muted
            .sink(receiveValue: { [weak self] value in
                self?.setAudio(muted: value)
            })
            .store(in: &cancellables)
        
        coordinator?.$aspect
            .sink(receiveValue: { [weak self] value in
                self?.change(aspect: value)
            })
            .store(in: &cancellables)
    }
    
    fileprivate func setAudio(muted: Bool) {
        guard mutedSetByUpdate == false else {
            mutedSetByUpdate = false
            return
        }
        VideoManager.shared.isMuted = muted
    }
    
    //MARK: - Video Player Management
    
    func cleanUp() {
        debugPrint("clean up called")
        stopObservingPlayback()
        eventHandler?.removeObservers()
        eventHandler = nil
    }
    
    func resetTimeAndProgress() {
        coordinator?.currentTime = 0
        coordinator?.totalTime = 0
        progressSetByUpdate = true
        coordinator?.progress = 0
    }
    
    func assingPlayer() {
        guard let layer = videoView.layer as? AVPlayerLayer else { return }
        layer.videoGravity = .resizeAspect
        layer.player = player
    }
    
    func setPlayerItemIfNeeded() {
        if playerItem == nil {
            var playerItem : CachingPlayerItem?
            if let pathToSave = settings?.filePath,
               FileManager.default.fileExists(atPath: pathToSave),
               let dataUrl = getAsURL(pathToSave),
               let videoData = try? Data(contentsOf: dataUrl) {
                playerItem = CachingPlayerItem(data: videoData, mimeType: "video/mp4", fileExtension: ".mp4")
                debugPrint("Video loaded from disk")
            } else if let urlString = settings?.url, let itemUrl = getAsURL(urlString) {
                playerItem = CachingPlayerItem(url: itemUrl)//AVPlayerItem(url: itemUrl)
            }
            guard let playerItem = playerItem else {
                debugPrint("VideoController - Could not create video url from \(settings?.url ?? "(no url)")")
                return
            }
            self.playerItem = playerItem
            player.replaceCurrentItem(with: playerItem)
            player.automaticallyWaitsToMinimizeStalling = false
            self.eventHandler = VideoEventHandler(player: player, playerItem: playerItem, delegate: self)
            coordinator?.currentVideo = settings?.id ?? ""
            if coordinator?.playlist.autoplay ?? false {
                playVideo()
            }
        }
    }
    
    func getAsURL(_ string: String) -> URL? {
        if string.hasPrefix("http") {
            return URL(string: string)
        }else{
            return URL(fileURLWithPath: string)
        }
    }
    
    func debugdebugPrint(_ string: String) {
        guard coordinator?.showLogs ?? false else { return }
        debugPrint(string)
    }
    
}

//
//MARK: - Video Controls
//
extension VideoController {
    
    public func playVideo() {
        if didReachEnd {
            if currentLoop == settings?.loopNumber || settings?.loopNumber == 0 {
                currentLoop = 0
                if let overrideStartTime = overrideStartTime {
                    player.seek(to: CMTime(seconds: overrideStartTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
                }else{
                    player.seek(to: CMTime.zero)
                }
                didReachEnd = false
            }
        }
        //outputVolume = AVAudioSession.sharedInstance().outputVolume
        muted = VideoManager.shared.isMuted
        observePlayback()
        player.play()
    }

    public func pauseVideo() {
        player.pause()
    }
    
    public func change(aspect: VideoAspect) {
        guard let layer = videoView.layer as? AVPlayerLayer else { return }
        switch aspect {
        case .fit:
            layer.videoGravity = .resizeAspect
        case .fill:
            layer.videoGravity = .resizeAspectFill
        }
    }
    
    public func rewindVideo(by seconds: Float64) {
        var newTime = CMTimeGetSeconds(player.currentTime()) - seconds
        if newTime <= 0 {
            newTime = 0
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
    }

    public func forwardVideo(by seconds: Float64) {
        if let duration = player.currentItem?.duration {
            var newTime = CMTimeGetSeconds(player.currentTime()) + seconds
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    public func goTo(percent: CGFloat) {
        let percent = VideoTools.clamp(percent, minValue: 0.0, maxValue: 1.0)
        let timeToSeek = VideoTools.lerp(v0: 0.0, v1: CGFloat(getDuration()), time: percent)
        if !timeToSeek.isNaN {
            stopObservingPlayback()
            pauseVideo()
            player.seek(to: CMTime(value: CMTimeValue(timeToSeek * 1000), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
            progress = percent
            if progress >= 1.0 {
                didReachEnd = true
            }else{
                didReachEnd = false
            }
        }
    }
    
    public func sliderChanged(percent: CGFloat) {
        guard progressSetByUpdate == false else {
            progressSetByUpdate = false
            return
        }
        var percent = VideoTools.clamp(percent, minValue: 0.0, maxValue: 1.0)
        if let overrideStartTime = overrideStartTime, let overrideEndTime = overrideEndTime {
            let realTime = VideoTools.lerp(v0: overrideStartTime, v1: overrideEndTime, time: percent)
            percent = VideoTools.calculatePercent(value: realTime, start: 0.0, end: getDuration())
        }
        goTo(percent: percent)
    }
    
    public func overrideDuration(startTime: CGFloat, endTime: CGFloat) {
        overrideStartTime = startTime
        overrideEndTime = endTime
        goTo(percent: startTime/endTime)
    }
    
    public func restoreOriginalDuration() {
        overrideStartTime = nil
        overrideEndTime = nil
        goTo(percent: 0.0)
    }
    
    public func goToNextVideo() {
        guard (coordinator?.playlist.videos.count ?? 0) > videoIndex + 1 else { return }
        pauseVideo()
        videoIndex += 1
        playerItem = nil
        resetTimeAndProgress()
        cleanUp()
        setPlayerItemIfNeeded()
    }
    
}

//
//MARK: - VideoEventHandlerDelegate Methods
//
extension VideoController : VideoEventHandlerDelegate {
    func VideoStatusChanged(status: VideoStatus) {
        debugPrint("Video status changed : \(status.rawValue)")
        coordinator?.state = status
        
        switch status {
        case .reachedEnd:
            saveIfNeeded()
            if let settings = settings,
               currentLoop < settings.loopNumber || currentLoop == -1 {
                currentLoop += 1
                player.seek(to: CMTime.zero)
                player.play()
            } else {
                goToNextVideo()
            }
            didReachEnd = true
        default:
            break
        }
        if !VideoManager.shared.isMuted && status == .playing {
            AudioBehaviour.ignoreSilentMode(.duckOthers).apply()
        }else{
            AudioBehaviour.ignoreSilentMode(.mixOthers).apply()
        }
    }
    
}

//
//MARK: - Update Methods
//
extension VideoController {
    
    fileprivate func getDuration() -> Float64 {
        let defaultDuration = 0.0001//If we need to divide seconds by duration to get percentage we dont get a NaN cause its not zero
        guard let duration = player.currentItem?.duration else { return defaultDuration}
        let durationSeconds = CMTimeGetSeconds(duration)
        guard !durationSeconds.isNaN else { return defaultDuration}
        return durationSeconds
    }
    
    fileprivate func stopObservingPlayback() {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    fileprivate func observePlayback(){
        guard timeObserver == nil else {return}
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))//CMTime(seconds: 1, preferredTimescale: 10)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {[weak self] (progressTime) in
            guard let duration = self?.getDuration() else { return }
            var progress = CMTimeGetSeconds(progressTime) / duration
            if progress > 1.0 {
                progress = 1.0
            }
            DispatchQueue.main.async { [weak self] in
                self?.progress = progress
            }
        }
    }
    
    fileprivate func updateProgress() {
        var progress = self.progress
        if let overrideStartTime = overrideStartTime, let overrideEndTime = overrideEndTime {
            let seconds = CMTimeGetSeconds(player.currentTime()) - overrideStartTime
            let duration = overrideEndTime - overrideStartTime
            progress = seconds / duration
            if progress > 1.0 {
                progress = 1.0
                didReachEnd = true
                pauseVideo()
            }
            coordinator?.currentTime = seconds
            coordinator?.totalTime = Double(duration)
        }else{
            let currentSeconds = CMTimeGetSeconds(player.currentTime())
            coordinator?.currentTime = currentSeconds.isFinite ? currentSeconds : 0
            coordinator?.totalTime = Double(getDuration())
        }
        progressSetByUpdate = true
        coordinator?.progress = Double(progress)
    }
    
}

//
//MARK: - Save Video
//
extension VideoController {
    
    fileprivate func saveIfNeeded() {
        guard !isSavingVideo,
              let playerItem = playerItem,
              let pathToSave = settings?.filePath,
              !FileManager.default.fileExists(atPath: pathToSave),
              let saveURL = getAsURL(pathToSave),
              let data = playerItem.mediaData
        else { return }
        
        isSavingVideo = true
        save(data: data, in: saveURL) { [weak self] success in
            self?.isSavingVideo = false
            debugPrint("Was the video saved? -> \(success ? "YES" : "NO")")
        }
    }
    
    func save(data: Data, in url: URL, completion: @escaping (Bool) -> Void) {
        queue.async(flags: .barrier) {
            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try data.write(to: url, options: .atomic)
                completion(true)
            } catch {
                debugPrint("Error saving video data : \(error)")
                completion(false)
            }
        }
    }
    
}

extension VideoController: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        debugPrint("File is downloaded and ready for storing")
        saveIfNeeded()
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        debugPrint("\(bytesDownloaded)/\(bytesExpected) = \(VideoTools.calculatePercent(value: CGFloat(bytesDownloaded), start: 0, end: CGFloat(bytesExpected)))")
    }
    
    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        debugPrint("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        debugPrint(error)
    }
    
}
