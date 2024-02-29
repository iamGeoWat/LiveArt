//
//  ResourceFetcher.swift
//  LiveArt
//
//  Created by GeoWat on 2/29/24.
//

import Foundation
// todo: use SwiftSoup as the HTML parser

func fetchWebPage(url: URL, completion: @escaping (String?) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        let content = String(data: data, encoding: .utf8)
        print("content", content)
        completion(content)
    }
    task.resume()
}

func findAmpAmbientVideoSrc(html: String) -> String? {
    let pattern = "<amp-ambient-video[^>]+src=\"([^\"]+)\""
    if let range = html.range(of: pattern, options: .regularExpression) {
        return String(html[range])
    }
    return nil
}

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


func main() {
    let url = URL(string: "https://music.apple.com/us/library/albums/l.M70OFE7?l=en-US")!
    print("jio")
    fetchWebPage(url: url) { content in
        guard let html = content, let videoSrc = findAmpAmbientVideoSrc(html: html) else {
            print("Failed to find video src")
            return
        }
        downloadFile(from: videoSrc) { fileURL in
            guard let fileURL = fileURL else {
                print("Failed to download file")
                return
            }
            print("File downloaded to: \(fileURL.path)")
        }
    }
}
//
//main()
//
//CFRunLoopRun()
