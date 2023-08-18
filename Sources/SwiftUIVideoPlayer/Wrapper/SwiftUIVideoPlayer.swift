import SwiftUI

public struct SwitfUIVideoPlayer : UIViewRepresentable {

    public init(coordinator: VideoCoordinator) {
        self.coordinator = coordinator
    }
    
    public let coordinator: VideoCoordinator

    public func makeUIView(context: Context) -> VideoView {
        let videoView = VideoManager.createVideo(coordinator: coordinator)
        return videoView
    }
    
    public func updateUIView(_ uiView: VideoView, context: Context) {}
}
