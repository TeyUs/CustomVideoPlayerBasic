//
//  VideoTableViewCell.swift
//  Ogr_AVKit
//
//  Created by teyhan.uslu on 3.08.2022.
//

import UIKit
import AVKit
import AVFoundation
import Kingfisher

class HomePageTableViewCell: UITableViewCell {

    @IBOutlet var imageV: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.tintColor = .red
        progressView.backgroundColor = .systemGray4
    }

    func prepareCell(video: Video){
        let videoURL = URL(string: video.url)
        let asset = AVAsset(url: videoURL!)
        
        //MARK: Only ProgressView on Cells
        if #available(iOS 15.0, *) {
            asset.loadMetadata(for: .unknown) {[weak self] _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    let duration = asset.duration
                    if CMTIME_IS_INVALID(duration) || duration.value == 0 { return }
                    print( video.lastDuration / Float(CMTimeGetSeconds(duration)))
                    self?.progressView.setProgress(video.lastDuration / Float(CMTimeGetSeconds(duration)), animated: true)
                }
            }
        } else {
            self.progressView.setProgress(0, animated: true)
        }
        
        nameLabel.text = video.name

        let imageUrl = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/\(video.imageUrl)")
        imageV.kf.setImage(with: imageUrl)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
