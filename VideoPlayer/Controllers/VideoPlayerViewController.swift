//
//  VideoPlayerViewController.swift
//  VideoPlayer
//
//  Created by Nayem on 1/14/19.
//  Copyright © 2019 Mufakkharul Islam Nayem. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayerViewController: AVPlayerViewController {
    
    var video: Video?
    var allowAutoPlay = true
    
    private var avPlayerReference: AVPlayer?
    private let imageView = UIImageView()
    private var playbackModeObservationToken: NSKeyValueObservation?
    private var foregroundNotification: NSObjectProtocol!
    private var backgroundNotification: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initially hide the playback controls when view is being loaded, will show in the viewDidAppear
        showsPlaybackControls = false
        // add the image view to the content overlay view so that image will be shown below the player controls
        contentOverlayView?.addSubview(imageView)
        // safely unwrap video object, download thumbnail image & creaate player item
        if let video = video {
            imageView.downloaded(from: video.thumbnailImageName, contentMode: .scaleAspectFill)
            
            let asset = AVAsset(url: video.sourceURL)
            let item = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: item)
            avPlayerReference = player
            
            // add AVPlayer observer to control image view show/hide
            playbackModeObservationToken = player?.observe(\.timeControlStatus) { [unowned self] (player, _) in
                switch player.timeControlStatus {
                case .paused:
                    self.imageView.isHidden = false
                case .playing:
                    self.imageView.isHidden = true
                case .waitingToPlayAtSpecifiedRate:
                    self.imageView.isHidden = false
                }
            }
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // essential for the image view to have its framing
        imageView.frame = contentOverlayView?.bounds ?? .zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show the playback controls back
        showsPlaybackControls = true
        // play the player if auto play is enabled
        if allowAutoPlay {
            player?.play()
        }
        
        foregroundNotification = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            self?.player = self?.avPlayerReference
        }
        backgroundNotification = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            self?.player = nil
        }
//        UIApplication.shared.beginReceivingRemoteControlEvents()
//        becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // pause the player obviously when view did disappear
        player?.pause()
        NotificationCenter.default.removeObserver(foregroundNotification)
        NotificationCenter.default.removeObserver(backgroundNotification)
//        UIApplication.shared.endReceivingRemoteControlEvents()
//        resignFirstResponder()
    }

}

extension VideoPlayerViewController: StoryboardInstantiable {
    static var storyboardName: UIStoryboard.Name {
        return UIStoryboard.Name.main
    }
}
