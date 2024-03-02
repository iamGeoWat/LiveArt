//
//  ResourceFetcher.swift
//  LiveArt
//
//  Created by GeoWat on 2/29/24.
//

import Foundation
import SwiftSoup
import SwiftUI

private var observation: NSKeyValueObservation?

func downloadFile(from urlString: String, completion: @escaping (URL?) -> Void) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
        guard let localURL = localURL, error == nil else {
            print("Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        completion(localURL)
    }
    task.resume()
}

func downloadHTML(url: URL, completion: @escaping (String?) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        let content = String(data: data, encoding: .utf8)
        completion(content)
    }
    task.resume()
}

func parseHTML(html: String) -> Document? {
    do {
        let doc: Document = try SwiftSoup.parse(html)
        return doc
    } catch {
        print("error")
        return nil
    }
}

func getVideoSrc(doc: Document) -> String? {
    do {
        let videoElement: Element = try doc.select("amp-ambient-video").first()!
        let videoSrc = try videoElement.attr("src")
        print(videoSrc)

        return videoSrc
    } catch {
        print("parser error")
        return nil
    }
}

func findLink(in fileURL: URL) -> String? {
    guard let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) else {
        print("Failed to load the file content.")
        return nil
    }
    let lines = fileContent.components(separatedBy: .newlines)
    for line in lines.reversed() {
        if line.hasPrefix("https") {
            return line
        }
    }
    return nil
}

func findFileName(in fileURL: URL) -> String? {
    guard let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) else {
        print("Failed to load the file content.")
        return nil
    }
    let lines = fileContent.components(separatedBy: .newlines)
    for line in lines.reversed() {
        if line.hasSuffix("mp4") {
            return line
        }
    }
    return nil
}

func getFinalVideoURL(url: String, fileName: String) -> String? {
    if var urlComponents = URLComponents(string: url),
       let url = urlComponents.url,
       var pathComponents = URL(string: url.absoluteString)?.pathComponents {
        pathComponents.removeLast()
        let newPath = (pathComponents + [fileName]).joined(separator: "/")
        urlComponents.path = newPath
        
        if let newURL = urlComponents.url {
            print("New URL: \(newURL)")
            return newURL.absoluteString
        } else {
            print("Failed to construct new URL")
            return nil
        }
    } else {
        print("Invalid URL")
        return nil
    }
}

func downloadVideo(from urlString: String, setProgress: @escaping (Double?, String?) -> Void, completion: @escaping (URL?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    let downloadTask = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
        guard let tempLocalUrl = tempLocalUrl, error == nil else {
            completion(nil)
            return
        }
        
        do {
            observation?.invalidate()
            
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let savedURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: savedURL.path) {
                try FileManager.default.removeItem(at: savedURL)
            }
            
            try FileManager.default.moveItem(at: tempLocalUrl, to: savedURL)
            completion(savedURL)
        } catch {
            completion(nil)
        }
    }
    observation = downloadTask.progress.observe(\.fractionCompleted) { progress, _ in
        setProgress(progress.fractionCompleted*45 + 50, nil)
    }
    downloadTask.resume()
}

func fetchAlbumArtVideo(from sourceURL: String, setProgress: @escaping (Double?, String?) -> Void, completion: @escaping (URL?) -> Void) {
    let url = URL(string: sourceURL)!
    setProgress(10, "Downloading HTML...")
    downloadHTML(url: url) { content in
        setProgress(20, "Parsing HTML...")
        guard let html = content else {
            print("error")
            completion(nil)
            return
        }
        guard let doc = parseHTML(html: html) else {
            print("error1")
            completion(nil)
            return
        }
        guard let videoSrc = getVideoSrc(doc: doc) else {
            print("error2")
            completion(nil)
            return
        }
        setProgress(30, "Downloading M3U8 File...")
        downloadFile(from: videoSrc) { fileURL in
            guard let fileURL = fileURL else {
                print("error3")
                completion(nil)
                return
            }
            guard let videoRawLink = findLink(in: fileURL) else {
                print("error4")
                completion(nil)
                return
            }
            setProgress(40, "Downloading 2nd M3U8 File...")
            downloadFile(from: videoRawLink) { rawFileURL in
                guard let rawFileURL = rawFileURL else {
                    print("error5")
                    completion(nil)
                    return
                }
                guard let fileName = findFileName(in: rawFileURL) else {
                    print("error4")
                    completion(nil)
                    return
                }
                guard let videoURL = getFinalVideoURL(url: videoRawLink, fileName: fileName) else {
                    print("error5")
                    completion(nil)
                    return
                }
                setProgress(50, "Downloading Album Art Video...")
                downloadVideo(from: videoURL, setProgress: setProgress) { videoFileURL in
                    completion(videoFileURL)
                }
            }
        }
    }
}
