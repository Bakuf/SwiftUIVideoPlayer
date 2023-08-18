//
//  ContentView.swift
//  SwiftUIVideoPlayer
//
//  Created by Rodrigo Galvez on 26/07/2023.
//

import SwiftUI
import SwiftUIVideoPlayer

struct ContentView: View {
    
    @ObservedObject var coordinator: VideoCoordinator = .create(playlist: TestVideo.all.map({ $0.convert() }))//.create(video: TestVideo.singleVideo.convert())
    
    var body: some View {
        ZStack {
            VStack {
                Button("Clear Video Storage") {
                    TestVideo.deleteVideoFolder()
                }
                
                SwitfUIVideoPlayer(coordinator: coordinator)
                    .overlay {
                        VStack {
                            Spacer()
                            HStack {
                                //Play-Pause
                                Button {
                                    if coordinator.state == .playing {
                                        coordinator.pauseVideo()
                                    } else {
                                        coordinator.playVideo()
                                    }
                                } label: {
                                    Circle()
                                        .background(.ultraThinMaterial)
                                        .overlay {
                                            Image(systemName: coordinator.state == .playing
                                                  ? "pause.fill"
                                                  : "play.fill")
                                                .imageScale(.large)
                                                .foregroundColor(.white)
                                        }
                                }
                                .clipShape(Circle())
                                .tint(.clear)
                                .frame(width: 40, height: 40)
                                
                                Button {
                                    coordinator.goToNextVideo()
                                } label: {
                                    Circle()
                                        .background(.ultraThinMaterial)
                                        .overlay {
                                            Image(systemName: "forward.fill")
                                                .imageScale(.large)
                                                .foregroundColor(.white)
                                        }
                                }
                                .clipShape(Circle())
                                .tint(.clear)
                                .frame(width: 40, height: 40)
                                
                                
                                
                                Spacer()
                                Text("\(coordinator.currentVideo)")
                                    .foregroundColor(.white)
                                Spacer()
                                
                                //Mute-Unmute
                                Button {
                                    coordinator.muted.toggle()
                                } label: {
                                    Circle()
                                        .background(.ultraThinMaterial)
                                        .overlay {
                                            Image(systemName: coordinator.muted ? "speaker.slash.fill" : "speaker.fill")
                                                .imageScale(.large)
                                                .foregroundColor(.white)
                                                .onTapGesture {
                                                    coordinator.muted.toggle()
                                                }
                                        }
                                }
                                .clipShape(Circle())
                                .tint(.clear)
                                .frame(width: 40, height: 40)
                                
                                //Aspect Change
                                Button {
                                    if coordinator.aspect == .fit {
                                        coordinator.aspect = .fill
                                    }else{
                                        coordinator.aspect = .fit
                                    }
                                } label: {
                                    Circle()
                                        .background(.ultraThinMaterial)
                                        .overlay {
                                            Image(systemName: coordinator.aspect == .fit ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                                                .imageScale(.large)
                                                .foregroundColor(.white)
                                                .onTapGesture {
                                                    coordinator.muted.toggle()
                                                }
                                        }
                                }
                                .clipShape(Circle())
                                .tint(.clear)
                                .frame(width: 40, height: 40)
                                
                            }
                            .padding()
                            
                            //Progress
                            if coordinator.state != .unknown {
                                HStack {
                                    Text("\(VideoTools.getHMSStringFrom(seconds: Int(coordinator.currentTime)))")
                                        .foregroundColor(.white)
                                    Slider(value: $coordinator.progress, in: 0...1)
                                    Text("\(VideoTools.getHMSStringFrom(seconds: Int(coordinator.totalTime)))")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                    }
                
            }
            .padding()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
