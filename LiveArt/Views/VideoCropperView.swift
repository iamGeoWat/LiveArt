//
//  VideoCropperView.swift
//  LiveArt
//
//  Created by GeoWat on 2024/3/22.
//

import SwiftUI
import AVKit

struct VideoCropperView: View {
    let rawVideoFileURL: URL
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var videoSize: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VideoPlayer(player: player)
                    .scaleEffect(scale)
                    .offset(offset)
                    .onAppear {
                        loadVideo()
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                                limitVideoMovement(in: geometry.size)
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(width: value.translation.width + offset.width,
                                                height: value.translation.height + offset.height)
                                limitVideoMovement(in: geometry.size)
                            }
                    )
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width, height: geometry.size.width * 16 / 9)
                    .allowsHitTesting(false)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .onTapGesture {
                cropVideo()
            }
        }
    }
    
    private func loadVideo() {
        playerItem = AVPlayerItem(url: rawVideoFileURL)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        guard let track = playerItem?.asset.tracks(withMediaType: .video).first else { return }
        let size = track.naturalSize.applying(track.preferredTransform)
        videoSize = CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    private func limitVideoMovement(in size: CGSize) {
        let maxScale = max(size.width / videoSize.width, size.height / videoSize.height)
        scale = min(scale, maxScale)
        
        let scaledVideoSize = CGSize(width: videoSize.width * scale, height: videoSize.height * scale)
        let maxOffsetX = (scaledVideoSize.width - size.width) / 2
        let maxOffsetY = (scaledVideoSize.height - size.height) / 2
        
        offset.width = min(max(offset.width, -maxOffsetX), maxOffsetX)
        offset.height = min(max(offset.height, -maxOffsetY), maxOffsetY)
    }
    
    private func cropVideo() {
        // TODO: Implement video cropping logic
        print("Cropping video...")
    }
}

struct VideoCropperViewPreview: View {
    let rawVideoFileURL = URL(string: "/Users/macbook/Documents/LiveArt/LiveArt/Resources/sos_raw.mp4")!

    var body: some View {
        VideoCropperView(rawVideoFileURL: rawVideoFileURL)
    }
}

#Preview {
    VideoCropperViewPreview()
}
