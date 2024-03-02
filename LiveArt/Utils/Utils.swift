//
//  Utils.swift
//  LiveArt
//
//  Created by GeoWat on 2024/2/28.
//

import Foundation
import Photos
import SwiftUI

enum ExportError: Error {
    case exportSessionFailed
    case couldNotFindDocumentDirectory
    case exportCancelled
    case unknown
}

enum LiveType {
    case Photo
    case Wallpaper
}

enum ProjectType: Codable {
    case LiveAlbum
    case UploadedVideo
}

var todayDate: String {
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.locale = Locale(identifier: "en_US")
    return dateFormatter.string(from: today)
}

func saveLivePhotoToLibrary(pairedImage image: URL, pairedVideo video: URL) {
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        switch status {
        case .authorized:
            print("authed, performing save")
        default:
            print("permission error")
        }
    }
    PHPhotoLibrary.shared().performChanges({
        let creationRequest = PHAssetCreationRequest.forAsset()
        let options = PHAssetResourceCreationOptions()
        creationRequest.addResource(with: .photo, fileURL: image, options: options)
        creationRequest.addResource(with: .pairedVideo, fileURL: video, options: options)
    }, completionHandler: { (success, error) in
        if error != nil {
            print(error as Any)
            print("Live Photo Not Saved", "The live photo was not saved to Photos.")
        }
        print("Live Photo Saved", "The live photo was successful0ly saved to Photos.")
    })
}

func setProgressAnimated(progress value: Binding<Double>, label: Binding<String>) -> (Double?, String?) -> Void {
    return { newValue, newLabel in
        withAnimation {
            if let newValue = newValue {
                value.wrappedValue = newValue
            }
            if let newLabel = newLabel {
                label.wrappedValue = newLabel
            }
        }
    }
}
