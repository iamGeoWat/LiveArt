//
//  Transcoder.swift
//  LiveArt
//
//  Created by GeoWat on 2/29/24.
//

import AVFoundation
import Foundation
import ImageIO
import UniformTypeIdentifiers
import SwiftUI

// This function adds metadata to a video asset
func transcodeLive(_ liveType: String, for inputFileName: String, progress progressValue: Binding<Double>, progressLabel: Binding<String>, videoCompletion: @escaping (Result<[URL], Error>) -> Void) {
    print("start transcoding")
    progressLabel.wrappedValue = "Loading resources and assets..."
    // Generate a unique identifier for the asset
    let assetIdentifier = UUID().uuidString
    
    // Define constants related to the metadata that will be added
    let kKeySpaceQuickTimeMetadata = "mdta"
    let kKeyContentIdentifier = "com.apple.quicktime.content.identifier"
    
    // Define the input and output URLs for the video processing
    guard let workingLivePhotoBundlePath = Bundle.main.path(forResource: "workingLivePhoto", ofType: "MOV") else {
        print("working lp not found")
        return
    }
    guard let inputMovieBundlePath = Bundle.main.path(forResource: "\(inputFileName)_raw", ofType: "mp4") else {
        print("input movie not found")
        return
    }
    guard let workingLivePhotoBundlePath = Bundle.main.path(forResource: "workingLivePhoto", ofType: "MOV") else {
        print("working lp not found")
        return
    }
    let workingLivePhotoURL = URL(fileURLWithPath: workingLivePhotoBundlePath)
    let inputURLRaw = URL(fileURLWithPath: inputMovieBundlePath)
    let assetRaw = AVURLAsset(url: inputURLRaw)
    
    let mixComposition = AVMutableComposition()
    guard let compositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
        return
    }
    
    progressLabel.wrappedValue = "Adding video and metadata tracks..."
    // Add the video track to the composition
    do {
        let sourceDuration = assetRaw.duration
        let sourceTrack = assetRaw.tracks(withMediaType: .video).first!
        
        try compositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: sourceDuration), of: sourceTrack, at: .zero)
        //      Create a video composition to apply the crop and scale
        let videoComposition = AVMutableVideoComposition(propertiesOf: mixComposition)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 60) // Set to 60 fps
        
        videoComposition.sourceTrackIDForFrameTiming = kCMPersistentTrackID_Invalid
        let instruction = AVMutableVideoCompositionInstruction()
        let targetDuration = CMTime(seconds: 1.0, preferredTimescale: 600)
        
        // Apply the cropping by setting the transform
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
        if liveType == "Wallpaper" {
            videoComposition.renderSize = CGSize(width: 1080, height: 1920)
            compositionTrack.scaleTimeRange(CMTimeRange(start: .zero, duration: sourceDuration), toDuration: targetDuration)
            instruction.timeRange = CMTimeRange(start: .zero, duration: targetDuration)
            
            
            let originalSize = compositionTrack.naturalSize
            let originalAspectRatio = originalSize.width / originalSize.height
            let targetSize = CGSize(width: 1080, height: 1920)
            let scaleFactor = targetSize.height / originalSize.height
            let scaledHeight = originalSize.height * scaleFactor
            let scaledWidth = originalSize.width * scaleFactor
            let offsetY = (scaledHeight - targetSize.height) / 2
            let offsetX = (scaledWidth - targetSize.width) / 3.65
            
            var transform = compositionTrack.preferredTransform // Handle video orientation
            // Apply scale and translation to center crop
            transform = transform.scaledBy(x: scaleFactor, y: scaleFactor)
            transform = transform.translatedBy(x: -offsetX, y: -offsetY)
            layerInstruction.setTransform(transform, at: .zero)
        } else if liveType == "Photo" {
            instruction.timeRange = CMTimeRange(start: .zero, duration: sourceDuration)
        }
    
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        
        // Load video assets from provided URLs
        let workingLivePhotoAsset = AVAsset(url: workingLivePhotoURL)
        
        // Create tracks in the composition for the video and metadata
        guard let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Couldn't add video track to the mix composition")
            return
        }
        
        // Create metadata tracks in the composition
        guard let metadataTrack1 = mixComposition.addMutableTrack(withMediaType: .metadata, preferredTrackID: kCMPersistentTrackID_Invalid),
              let metadataTrack2 = mixComposition.addMutableTrack(withMediaType: .metadata, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Couldn't add metadata tracks to the mix composition")
            return
        }
        
        // Define time ranges and insert them into the composition tracks
        do {
            try metadataTrack1.insertTimeRange(CMTimeRange(start: .zero, duration: workingLivePhotoAsset.duration), of: workingLivePhotoAsset.tracks(withMediaType: .metadata)[0], at: .zero)
            try metadataTrack2.insertTimeRange(CMTimeRange(start: .zero, duration: workingLivePhotoAsset.duration), of: workingLivePhotoAsset.tracks(withMediaType: .metadata)[1], at: .zero)
        } catch {
            print("Error inserting time ranges: \(error)")
            return
        }
        
        // Create metadata items to be added to the video
        let contentIdentifierItem = AVMutableMetadataItem()
        contentIdentifierItem.key = kKeyContentIdentifier as (NSCopying & NSObjectProtocol)
        contentIdentifierItem.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        contentIdentifierItem.value = assetIdentifier as (NSCopying & NSObjectProtocol)
        
        // Create metadata items
        let makeItem = AVMutableMetadataItem()
        makeItem.key = AVMetadataKey.commonKeyMake as (NSCopying & NSObjectProtocol)?
        makeItem.keySpace = AVMetadataKeySpace.common
        makeItem.value = "Apple" as (NSCopying & NSObjectProtocol)?
        makeItem.locale = Locale.current
        
        let modelItem = AVMutableMetadataItem()
        modelItem.key = AVMetadataKey.commonKeyModel as (NSCopying & NSObjectProtocol)?
        modelItem.keySpace = AVMetadataKeySpace.common
        modelItem.value = "iPhone" as (NSCopying & NSObjectProtocol)?
        modelItem.locale = Locale.current
        
        let softwareItem = AVMutableMetadataItem()
        softwareItem.key = AVMetadataKey.commonKeySoftware as (NSCopying & NSObjectProtocol)?
        softwareItem.keySpace = AVMetadataKeySpace.common
        softwareItem.value = "17.3.1" as (NSCopying & NSObjectProtocol)?
        softwareItem.locale = Locale.current
        
        let metadataItem = AVMutableMetadataItem()
        metadataItem.key = AVMetadataKey.commonKeyCreationDate as (NSCopying & NSObjectProtocol)?
        metadataItem.keySpace = AVMetadataKeySpace.common
        metadataItem.value = ISO8601DateFormatter().string(from: Date()) as (NSCopying & NSObjectProtocol)?
        metadataItem.locale = Locale.current
        
        progressLabel.wrappedValue = "Exporting video for Live \(liveType), it may take a while..."
        // Set up and start the video export process
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHEVCHighestQualityWithAlpha) else {
            videoCompletion(.failure(ExportError.exportSessionFailed))
            return
        }
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            videoCompletion(.failure(ExportError.couldNotFindDocumentDirectory))
            return
        }
        let outputURL = documentDirectoryURL.appendingPathComponent("\(inputFileName)_Live\(liveType)_video.MOV")
        // Remove existing file at output URL if any
        try? FileManager.default.removeItem(at: outputURL)
        exporter.outputURL = outputURL
        exporter.outputFileType = .mov
        exporter.metadata = [contentIdentifierItem, makeItem, modelItem, softwareItem, metadataItem]
        exporter.videoComposition = videoComposition
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation {
                if liveType == "Wallpaper" {
                    progressValue.wrappedValue = Double(exporter.progress * 50.0) + 50
                } else if liveType == "Photo" {
                    progressValue.wrappedValue = Double(exporter.progress * 50.0)
                }
            }
            if exporter.status == .completed || exporter.status == .failed {
                timer.invalidate()
            }
        }
        exporter.exportAsynchronously {
            switch exporter.status {
            case .completed:
                print("Video transcoding compelted")
                progressLabel.wrappedValue = "Exporting photo for Live \(liveType), it may take a while..."
                extractFramesAndSaveHEIC(videoURL: outputURL) { result in
                    switch result {
                    case .success(let photoURL):
                        print("Exported photo successfully to \(photoURL)")
                        print("Exported video successfully to \(outputURL)")
                        videoCompletion(.success([outputURL, photoURL]))
                    default:
                        videoCompletion(.failure(ExportError.unknown))
                    }
                }
            case .failed:
                videoCompletion(.failure(exporter.error ?? ExportError.unknown))
            case .cancelled:
                videoCompletion(.failure(ExportError.exportCancelled))
            default:
                videoCompletion(.failure(ExportError.unknown))
            }
        }
        
        
        // ----------------------------------------------------------------------------------------------
        
        
        // This function extracts frames from a video and saves them as a HEIC image
        func extractFramesAndSaveHEIC(videoURL: URL, photoCompletion: @escaping (Result<URL, Error>) -> Void) {
            print("running extract", videoURL)
            // Load the video asset from which frames will be extracted
            let videoAsset = AVAsset(url: videoURL)
            
            // Ensure the video contains video tracks
            guard videoAsset.tracks(withMediaType: .video).count > 0 else {
                print("No video tracks found in asset.")
                return
            }
            
            // Set up the image generator to extract frames from the video
            let frameRate: Int32 = 60
            let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
            if liveType == "Wallpaper" {
                imageGenerator.maximumSize = CGSize(width: 1080, height: 1920)
            }
            

            imageGenerator.requestedTimeToleranceBefore = CMTime(value: 1, timescale: frameRate)
            imageGenerator.requestedTimeToleranceAfter = CMTime(value: 1, timescale: frameRate)
            let durationInSeconds = CMTimeGetSeconds(videoAsset.duration)
            let totalFrames = Int(durationInSeconds * Double(frameRate))
            var images = [CGImage]()
            let frameTime = CMTimeMake(value: Int64(totalFrames / 2), timescale: frameRate)
            do {
                let imageRef = try imageGenerator.copyCGImage(at: frameTime, actualTime: nil)
                images.append(imageRef)
            } catch {
                print("Error generating frame at index \(Int64(totalFrames / 2)): \(error)")
            }
            // Define metadata for the HEIC image
            let makerNote = NSMutableDictionary()
            makerNote.setObject(assetIdentifier, forKey: "17" as NSCopying)
            let metadata = NSMutableDictionary()
            metadata.setObject(makerNote, forKey: kCGImagePropertyMakerAppleDictionary as String as NSCopying)
            let exifVersion = NSMutableDictionary()
            exifVersion.setObject([2,2,1], forKey: kCGImagePropertyExifVersion as String as NSCopying)
            metadata.setObject(exifVersion, forKey: kCGImagePropertyExifDictionary as String as NSCopying)
            
            // Check if there are any images to save
            guard images.count > 0 else {
                print("No frames were extracted from the video.")
                return
            }
            
            // Save the extracted images as a HEIC file
            guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                videoCompletion(.failure(ExportError.couldNotFindDocumentDirectory))
                return
            }
            let url = documentDirectoryURL.appendingPathComponent("\(inputFileName)_Live\(liveType)_photo.HEIC")
            guard let destination = CGImageDestinationCreateWithURL(url as CFURL, AVFileType.heic.rawValue as CFString, images.count, nil) else {
                print("Failed to create image destination.")
                return
            }
            
            for image in images {
                // Create a CGContext for drawing the resized image
                var width: Int = 0
                var height: Int = 0
                if liveType == "Wallpaper" {
                    width = 1080
                    height = 1920
                } else if liveType == "Photo" {
                    width = image.width
                    height = image.height
                }
                
                guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: image.bitsPerComponent, bytesPerRow: 0, space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                    print("Unable to create graphics context.")
                    continue
                }
            
                // Draw the original image into the context, resizing it
                context.interpolationQuality = .high
                context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            
                // Extract the resized image from the context
                guard let resizedImage = context.makeImage() else {
                    print("Failed to create resized image.")
                    continue
                }
                CGImageDestinationAddImage(destination, resizedImage, metadata)
            }
            
            if !CGImageDestinationFinalize(destination) {
                photoCompletion(.failure(ExportError.exportSessionFailed))
                print("Failed to save HEIC image.")
            } else {
                photoCompletion(.success(url))
                print("Saved HEIC image successfully!")
            }
        }
    } catch {
        videoCompletion(.failure(ExportError.unknown))
        return
    }
}


enum ExportError: Error {
    case exportSessionFailed
    case couldNotFindDocumentDirectory
    case exportCancelled
    case unknown
}
