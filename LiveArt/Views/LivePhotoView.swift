//
//  SwiftUIView.swift
//
//
//  Created by GeoWat on 2024/2/12.
//

import SwiftUI
import PhotosUI

struct LivePhotoViewRep: UIViewRepresentable {
    var livePhoto: PHLivePhoto
    @Binding var shouldPlay: Bool
    var repetitivePlay: Bool
    
    func makeUIView(context: Context) -> PHLivePhotoView {
        let livePhotoView = PHLivePhotoView()
        livePhotoView.livePhoto = livePhoto
        return livePhotoView
    }
    
    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
        if shouldPlay {
            uiView.startPlayback(with: .full)
            DispatchQueue.main.async {
                // Reset shouldPlay to false to allow for future playbacks
                self.shouldPlay = false
            }
        }
        if repetitivePlay {
            uiView.startPlayback(with: .full)
            uiView.delegate = context.coordinator
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHLivePhotoViewDelegate {
            var parent: LivePhotoViewRep

            init(_ parent: LivePhotoViewRep) {
                self.parent = parent
            }

            func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
                guard parent.repetitivePlay ?? false else { return }
                livePhotoView.startPlayback(with: .full) // Restart playback
            }
        }
}
