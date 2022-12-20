//
//  Video.swift
//  Ogr_AVKit
//
//  Created by teyhan.uslu on 6.09.2022.
//

import Foundation
import CoreMedia

class Video {
    let url: String
    let name: String
    let imageUrl: String
    var lastDuration: Float {
        get {
            getTime()
        } set {
            saveTime(time: newValue)
        }
    }

    internal init(url: String, name: String, imageUrl: String) {
        self.url = url
        self.name = name
        self.imageUrl = imageUrl
    }
}

var videos: [Video] = [Video(url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", name: "Big Buck Bunny", imageUrl: "images/BigBuckBunny.jpg"),
                       Video(url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", name: "Elephant Dream", imageUrl: "images/ElephantsDream.jpg"),
                       Video(url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", name: "For Bigger Blazes", imageUrl: "images/ForBiggerBlazes.jpg")]

extension Video{
    private func getTime() -> Float{
        let time = UserDefaults.standard.float(forKey: self.name)
        if CMTIME_IS_INVALID(time.asCMTime()) {
            return 0
        }else {
            return time
        }
    }

    private func saveTime(time: Float){
        UserDefaults.standard.set(time, forKey: self.name)
    }
}

extension Float {
    func asCMTime() -> CMTime {
        return CMTimeMake(value: Int64(self), timescale: 1)
    }
}
