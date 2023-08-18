//
//  VideoTools.swift
//
//
//  Created by Rodrigo Galvez on 20/01/22.
//

import Foundation
import UIKit
import AVFoundation

public class VideoTools {
    
    public class func calculatePercent(value: CGFloat, start: CGFloat, end: CGFloat) -> CGFloat{
        if start == end { return 1.0 }
        let diff = value - start
        let scope = end - start
        var progress : CGFloat = 0.0
        if(diff != 0.0) {
            progress = diff / scope
        } else {
            progress = 0.0
        }
        return progress;
    }
    
    public class func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T : Comparable {
        return min(max(value, minValue), maxValue)
    }
    
    public class func lerp(v0: CGFloat, v1: CGFloat, time: CGFloat) -> CGFloat {
        return (1.0 - time) * v0 + time * v1;
    }
    
    public class func sendToMainThread(block: @escaping (()->Void)){
        if Thread.isMainThread {
            block()
        }else{
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    public class func hmsFrom(seconds: Int) -> (hours: Int,minutes: Int,seconds: Int) {
            return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    public class func getStringFrom(seconds: Int) -> String {
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    public class func getHMSStringFrom(seconds: Int) -> String {
        let time = VideoTools.hmsFrom(seconds: seconds)
        var fullTime = VideoTools.getStringFrom(seconds: time.seconds)
        if time.minutes != 0 {
            if time.hours == 0 {
                return "\(time.minutes):" + fullTime
            }else{
                fullTime = VideoTools.getStringFrom(seconds: time.minutes) + ":" + fullTime
            }
        }else{
            return "0:\(fullTime)"
        }
        if time.hours != 0 {
            fullTime = "\(time.hours):" + fullTime
        }
        return fullTime
    }
    
    public class func aspectRatio(width: CGFloat, height: CGFloat, in rect: CGRect = UIScreen.main.bounds) -> CGRect {
        AVMakeRect(aspectRatio: .init(width: width, height: height), insideRect: rect)
    }
    
}
