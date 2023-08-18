# SwiftUIVideoPlayer ![Platform](https://img.shields.io/badge/Platforms-%20iOS%20-lightgrey.svg) ![Swift 5](https://img.shields.io/badge/Swift-5-F28D00.svg) [![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

SwiftUI Wrapper for AVPlayer

Features:

- Can play one or multiple videos (Playlist)
- Audio control to mute/unmute and interact with other audio sources
- Can adjust the aspect ratio during playback
- Can control the playback timeline
- If a save path is included, the video can be stored locally and then automatilly loaded from disk next time.

There is also a class called VideoTools that contains some conveniance methods to display the time of the videos.

## Acknowledgments

This package have a dependency for storing the videos locally, I added the source directly since it doesn't support spm, here is their GitHub link [CachingPlayerItem](https://github.com/neekeetab/CachingPlayerItem/tree/master)

## Quick Start

Just import SwiftUIVideoPlayer to your swiftUI view and create both a `VideoCoordinator` and a `SwitfUIVideoPlayer` view inside

```swift
@ObservedObject var coordinator: VideoCoordinator = .create(video: VideoSettings(id: "Video Id",
                                                                                 url: "Video Url"))

var body: some View {
    SwitfUIVideoPlayer(coordinator: coordinator)
}
```

To save the video locally, you need to provide a save destination, you can set it on the `VideoSettings` property named `pathToSave` like this 

```swift

VideoSettings(id: id,
              url: url,
              pathToSave: pathToSave,
              loopNumber: 0)
              
```

If you want to know how to use the other features check out the example project.

Note: I added the "App Transport Security Settings" to "Allow Arbitrary Loads" to the info plist so the player could load any url without any concern for secury, but if you plan to use this comercially then add only your trusted urls to comply with Apple security policies. If you don't do this then you might not be able to see the videos playing and will get some warnings printed on the console.

## Installation

`SwiftUIVideoPlayer` can be installed using [Swift Package Manager](https://swift.org/package-manager/), or manually.

### Swift Package Manager

[Swift Package Manager](https://github.com/apple/swift-package-manager) requires Swift version 4.0 or higher. First, create a `Package.swift` file. It should look like:

```swift
dependencies: [
    .package(url: "https://github.com/Bakuf/SwiftUIVideoPlayer.git", from: "0.0.1")
]
```

`swift build` should then pull in and compile `SwiftUIVideoPlayer` for you to begin using.


## License

SwiftUIVideoPlayer is available under the MIT license. See [the LICENSE file](./license.txt) for more information.
