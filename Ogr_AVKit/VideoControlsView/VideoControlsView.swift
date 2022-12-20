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

    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    
    @IBOutlet var allView: UIView!
    @IBOutlet var playedTimeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var scrubber: UISlider!
    @IBOutlet var playPauseButton: UIButton!

    func prepareScreenElements(delegate: VideoScreenViewController, player: AVPlayer) {
        viewController = delegate
        self.player = player
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
                                       queue: DispatchQueue.main) { [weak self] _ in
            if player.currentItem?.status == .readyToPlay {
                self?.updateVideoPlayerSlider()
             }
         }
        setButtonsImages() //just about UI
    }
    
    func setButtonsImages() {
        backwardButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50), forImageIn: .normal)
        forwardButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50), forImageIn: .normal)
        playPauseButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50), forImageIn: .normal)
    }
    
    func updateVideoPlayerSlider() {
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if CMTIME_IS_INVALID(duration) || duration.value == 0 { return }
            let currentTime = currentItem.currentTime()
            
            scrubber.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            
            playedTimeLabel.text = timeIntervalToString(durationTime: CMTimeGetSeconds(currentTime))
            
            if CMTimeGetSeconds(currentTime).isEqual(to: CMTimeGetSeconds(duration)) {
                stopVideo(current: 0)
            }
            
            if is_start {
                is_start = false
                totalTimeLabel.text = timeIntervalToString(durationTime: CMTimeGetSeconds(duration))
            }
        }
    }
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        print(#function)
        guard let btn:UIButton = sender as? UIButton else { return }
        if player?.isPlaying == false {
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
        stopVideo()
    }
    
    @IBAction func backwardButtonTapped(_ sender: Any) {
        print(#function)
        changeSeekTime(jump: -10)
        backwardButton.isHighlighted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            backwardButton.isHighlighted = false
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        print(#function)
        changeSeekTime(jump: 10)
        forwardButton.isHighlighted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            forwardButton.isHighlighted = false
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
    
    private func stopVideo(current: Float64? = nil) {
        viewController?.video.lastDuration = Float(current ?? getCurrentTime())
        //player = nil
        player?.replaceCurrentItem(with: nil)
        viewController?.popThePage()
    }
    
    private func getCurrentTime() -> Float64 {
        if let currentItem = player?.currentItem {
            return Float64(CMTimeGetSeconds(currentItem.currentTime()))
        }
        return 0
    }
}
