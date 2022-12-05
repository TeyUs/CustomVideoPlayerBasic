//
//  VideoControlsView.swift
//  Ogr_AVKit
//
//  Created by teyhan.uslu on 27.08.2022.
//

import UIKit
import AVKit

class VideoControlsView: UIView {

    override init(frame: CGRect) {
       super.init(frame: frame)
        commonInit()
     }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("VideoControlsView", owner: self)
        addSubview(allView)
        allView.frame = self.bounds
        allView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    var viewController: VideoScreenViewController?
    var player: AVPlayer?
    var is_start = true

    @IBOutlet var backBTN: UIButton!
    @IBOutlet var forBTN: UIButton!
    
    @IBOutlet var allView: UIView!
    @IBOutlet var playedTimeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var scrubber: UISlider!
    @IBOutlet var playPauseButton: UIButton!

    func prepareScreenElements(delegate: VideoScreenViewController, player: AVPlayer) {
        viewController = delegate
        self.player = player
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player?.currentItem?.status == .readyToPlay {
                 self.updateVideoPlayerSlider()
             }
         }
        backBTN.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50), forImageIn: .normal)
        forBTN.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50), forImageIn: .normal)
        playPauseButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50), forImageIn: .normal)
    }

    func updateVideoPlayerSlider() {
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if CMTIME_IS_INVALID(duration) || duration.value == 0 { return;}
            let currentTime = currentItem.currentTime()
            scrubber.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            playedTimeLabel.text = timeIntervalToString(durationTime: CMTimeGetSeconds(currentTime))
            if is_start {
                totalTimeLabel.text = timeIntervalToString(durationTime: CMTimeGetSeconds(duration))
                is_start = false
            }
            viewController?.video.lastDuration = currentTime
            checkStop(current: CMTimeGetSeconds(currentTime), duration: CMTimeGetSeconds(duration))
        }
    }

    private func checkStop(current: Float64, duration: Float64){
        print("current:\(current)  duration:\(duration) ")
        if current.isEqual(to: duration), duration != 0 {
            viewController?.video.resetTime()
            stopVideo()
            viewController?.popThePage()
        }
    }

    @IBAction func playPauseButtonTapped(_ sender: Any) {
        print(#function)
        guard let btn:UIButton = sender as? UIButton else { return }
        if player?.isPlaying == true {
            btn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player?.play()
        } else {
            btn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player?.pause()
        }
    }

    @IBAction func scrubber(_ sender: Any) {
        guard let duration = player?.currentItem?.duration else { return }
        if CMTIME_IS_INVALID(duration) || duration.value == 0 { return }
        
        let value = Float64(scrubber.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player?.seek(to: seekTime )
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        print(#function)
        player?.replaceCurrentItem(with: nil)
        stopVideo()
        viewController?.popThePage()
    }
    
    @IBAction func backwardButtonTapped(_ sender: Any) {
        print(#function)
        changeSeekTime(jump: -10)
        backBTN.isHighlighted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            backBTN.isHighlighted = false
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        print(#function)
        changeSeekTime(jump: 10)
        forBTN.isHighlighted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            forBTN.isHighlighted = false
        }
    }

    @objc private func changeSeekTime(jump: Int) {
        guard let duration = player?.currentItem?.duration else { return }
        if CMTIME_IS_INVALID(duration) || duration.value == 0 { return }
        var value = Float64(scrubber.value) * CMTimeGetSeconds(duration) + Float64(jump)
        if value < 0{
            value = 0
        }
        if value > CMTimeGetSeconds(duration){
            value = CMTimeGetSeconds(duration)
        }
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player?.seek(to: seekTime )
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension VideoControlsView {
    private func timeIntervalToString(durationTime: TimeInterval) -> String {
        let minutes = Int(durationTime) / 60
        let seconds = Int(durationTime) % 60

        var minStr: String = "\(minutes)"
        if minutes < 10{
            minStr = "0\(minutes)"
        }
        var secStr: String = "\(seconds)"
        if seconds < 10{
            secStr = "0\(seconds)"
        }
        let videoDuration = "\(minStr):\(secStr)"
        return videoDuration
    }
    
    private func stopVideo() {
        viewController?.player = nil
        player = nil
    }
}
