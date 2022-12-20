//
//  VideoScreenViewController.swift
//  Ogr_AVKit
//
//  Created by teyhan.uslu on 7.08.2022.
//

import UIKit
import AVKit
import AVFoundation

class VideoScreenViewController: UIViewController {
    
    var videoController: VideoControlsView!
    var video: Video!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscapeRight }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    func setupPlayer(){
        let player = AVPlayer(url: URL(string: video.url)!)
        player.seek(to: video.lastDuration.asCMTime())
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: (self.view.frame.height),
                                   height: (self.view.frame.width))
        view.backgroundColor = .black
        self.view.layer.addSublayer(playerLayer)
        player.play()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchedScreen(_:)))
        self.view.addGestureRecognizer(tap)
        
        videoController = VideoControlsView()
        videoController.frame = CGRect(x: 0, y: 0 , width: (self.view.frame.height), height: (self.view.frame.width))
        videoController.prepareScreenElements(delegate: self, player: player)
        view.addSubview(videoController)
        view.bringSubviewToFront(videoController)
    }
    
    @objc func touchedScreen(_ sender: UITapGestureRecognizer? = nil) {
        shouldControllerAppear(appear: nil)
    }
    
    func popThePage(){
        dismiss(animated: true, completion: nil)
    }
    
    func shouldControllerAppear(appear: Bool?){
        switch appear{
        case true:
            videoController.isHidden = false
        case false:
            videoController.isHidden = true
        case nil:
            videoController.isHidden = !videoController.isHidden
        case .some(_): break
        }
    }
}
