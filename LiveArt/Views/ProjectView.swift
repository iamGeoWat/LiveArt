//
//  ProjectView.swift
//  LiveArt
//
//  Created by GeoWat on 2/29/24.
//

import SwiftUI
import Photos
import PhotosUI
import TipKit

struct ProjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var project: Project
    @State private var livePhoto: PHLivePhoto?
    @State private var liveWallpaper: PHLivePhoto?
    
    
    @State private var albumURL: String = "https://music.apple.com/us/playlist/me-and-bae/pl.a13aca4f4f2c45538472de9014057cc0"
    @State private var timer: Timer?
    @State private var isShowingShareSheet = false
    @State private var isShowingInvokeFailed = false
    
    @State private var generateProgress = 0.0
    @State private var generateProgressLabel = "Ready"
    @State private var fetchProgress = 0.0
    @State private var fetchProgressLabel = "Ready"
    @State private var isShowingGenerateFailed = false
    
    let stepIds: [UUID] = (1...8).map { _ in UUID() }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    // Title
                    Text(project.name)
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                        .padding(.top, 30)
                        .padding(.leading)
                        .padding(.bottom, 30)
                        .id(stepIds[1])
                    // Step 1
                    HStack(alignment: .top) {
                        VStack(spacing: 2) {
                            Image(systemName: "circle.fill")
                                .imageScale(.medium)
                                .font(.footnote)
                            Rectangle()
                                .frame(width: 2)
                                .clipped()
                        }
                        .foregroundColor(colorForStep(1, when: project.currentStep))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step 1:")
                                .font(.footnote)
                            Text("Provide a link to an Apple Music album")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                TextField("Enter URL", text: $albumURL)
                                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Gives the text field a rounded border
                                    .padding(.trailing, 8)
                                Button("Fetch") {
                                    withAnimation {
                                        fetchAlbum(scrollViewProxy: proxy)
                                    }
                                    
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                            }
                            .padding(.bottom, 10)
                            ProgressView(value: fetchProgress, total: 100) {} currentValueLabel: {
                                Text(fetchProgressLabel)
                            }
                            .padding()
                            paddedAnchor(forStep: 2)
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(project.currentStep != 1 ? 0.5: 1.0)
                        .disabled(project.currentStep != 1)
                    }
                    // Step 2
                    HStack(alignment: .top) {
                        VStack(spacing: 2) {
                            Image(systemName: "circle.fill")
                                .imageScale(.medium)
                                .font(.footnote)
                            Rectangle()
                                .frame(width: 2)
                                .clipped()
                        }
                        .foregroundColor(colorForStep(2, when: project.currentStep))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step 2:")
                                .font(.footnote)
                            Text("Generate Live Photo")
                                .font(.headline)
                                .padding(.bottom, 5)
                            HStack {
                                Button("Generate") {
                                    withAnimation {
                                        generateProgressLabel = "processing live photo..."
                                    }
                                    generateLive(.Photo) { state in
                                        if case .failed = state {
                                            isShowingGenerateFailed = true
                                            return
                                        }
                                        generateLive(.Wallpaper) { state in
                                            if case .failed = state {
                                                isShowingGenerateFailed = true
                                                return
                                            }
                                            print("goto step 3")
                                            project.workInProgress = false
                                            goToStep(3, with: proxy)
                                        }
                                    }
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                                .alert("Generate failed, please try use other video resources or contact support.", isPresented: $isShowingGenerateFailed) {
                                    Button("OK", role: .cancel) {}
                                }
                                if generateProgress != 0 && generateProgress != 100 {
                                    ProgressView()
                                        .padding(.leading)
                                }
                                Spacer()
                            }
                            .padding(.top)
                            ProgressView(value: generateProgress, total: 100) {} currentValueLabel: {
                                Text(generateProgressLabel)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .opacity(project.currentStep != 2 ? 0.5: 1.0)
                        .disabled(project.currentStep != 2)
                    }
                    // Finished
                    Group {
                        HStack(alignment: .top) {
                            VStack(spacing: 2) {
                                Image(systemName: "circle.fill")
                                    .imageScale(.medium)
                                    .font(.footnote)
                            }
                            .foregroundColor(colorForStep(3, when: project.currentStep))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Finished")
                                    .font(.footnote)
                                HStack {
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .padding(.bottom, 30)
                        }
                        .id(stepIds[3])
                        // Project Result
                        Text("View your result")
                            .font(.largeTitle)
                            .fontDesign(.monospaced)
                            .padding(.bottom, 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Set Live Wallpaper")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text("You have the option to manually set it via the Photos App or use our one-click shortcut to bring up the wallpaper setting screen.")
                                .padding(.bottom, 10)
                            HStack {
                                Button("Import Shortcut") {
                                    isShowingShareSheet = true
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .sheet(isPresented: $isShowingShareSheet) {
                                    if let shortcutURL = getShortcutURL() {
                                        ActivityView(activityItems: [shortcutURL])
                                    }
                                }
                                Button("Set") {
                                    invokeShortcut(completion: { success in
                                        if !success {
                                            isShowingInvokeFailed = true
                                        }
                                    })
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .alert("Set failed. Please import the shortcut to your Shortcut App first.", isPresented: $isShowingInvokeFailed) {
                                    Button("OK", role: .cancel) {}
                                }
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        VStack {
                            VStack {
                                ResultView(livePhoto: livePhoto, liveWallpaper: liveWallpaper) { liveType in
                                    switch liveType {
                                    case .Photo:
                                        if let pairedImage = project.livePhoto?.pairedImage,
                                           let pairedVideo = project.livePhoto?.pairedVideo {
                                            saveLivePhotoToLibrary(pairedImage: pairedImage, pairedVideo: pairedVideo)
                                        }
                                    case .Wallpaper:
                                        if let pairedImage = project.liveWallpaper?.pairedImage,
                                           let pairedVideo = project.liveWallpaper?.pairedVideo {
                                            saveLivePhotoToLibrary(pairedImage: pairedImage, pairedVideo: pairedVideo)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: 500)
                            Spacer()
                        }
                    }
                    .opacity(project.currentStep != 3 ? 0.5: 1.0)
                    .disabled(project.currentStep != 3)
                }
                .padding(.horizontal)
                .onAppear {
                    if let projectLivePhoto = project.livePhoto,
                       let projectLiveWallpaper = project.liveWallpaper {
                        requestLivePhoto(photoURL: projectLivePhoto.pairedImage, videoURL: projectLivePhoto.pairedVideo, type: .Photo) { livePhotoResult in
                            livePhoto = livePhotoResult
                        }
                        requestLivePhoto(photoURL: projectLiveWallpaper.pairedImage, videoURL: projectLiveWallpaper.pairedVideo, type: .Wallpaper) { livePhotoResult in
                            liveWallpaper = livePhotoResult
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print(project.currentStep)
                        withAnimation {
                            goToStep(project.currentStep, with: proxy)
                        }
                    }
                }
                .frame(maxWidth: 600)
                
            }
        }
    }
    
    func requestLivePhoto(photoURL: URL, videoURL: URL, type: LiveType, completion: @escaping (PHLivePhoto) -> Void) {
        PHLivePhoto.request(withResourceFileURLs: [photoURL, videoURL], placeholderImage: nil, targetSize: CGSize.zero, contentMode: PHImageContentMode.aspectFit) { livePhotoResult, info in
            if let isDegraded = info[PHLivePhotoInfoIsDegradedKey] as? Bool, isDegraded {
                return
            }
            guard let livePhotoResult = livePhotoResult else {
                return
            }
            completion(livePhotoResult)
        }
    }
    
    func generateLive(_ type: LiveType, completion: @escaping (TaskState) -> Void) {
        let setProgress = setProgressAnimated(progress: $generateProgress, label: $generateProgressLabel)
        guard let rawVideoFileURL = project.rawVideoFileURL else {
            print("no video file")
            completion(.failed)
            return
        }
        transcodeLive(type, for: rawVideoFileURL, setProgress: setProgress) { result in
            switch result {
            case .success(let urls):
                let videoURL = urls[0]
                let photoURL = urls[1]
                print("gen succeeded")
                project.coverPhoto = photoURL
                setProgress(nil, "Generating Live \(type)...")
                requestLivePhoto(photoURL: photoURL, videoURL: videoURL, type: type) { livePhotoResult in
                    if type == .Photo {
                        withAnimation {
                            livePhoto = livePhotoResult
                            project.livePhoto = LivePhoto(pairedImage: photoURL, pairedVideo: videoURL)
                        }
                        setProgress(50, "Live Photo generated!")
                        completion(.success)
                    } else if type == .Wallpaper {
                        withAnimation {
                            project.liveWallpaper = LivePhoto(pairedImage: photoURL, pairedVideo: videoURL)
                            liveWallpaper = livePhotoResult

                        }
                        setProgress(100, "Live Wallpaper generated. Done.")
                        completion(.success)
                    }
                }
            default:
                print("gen lp failed")
            }
        }
    }
    
    func paddedAnchor(forStep step: Int) -> some View {
        Color.clear
            .frame(height: 40)
            .id(stepIds[step])
    }
    
    func colorForStep(_ step: Int, when currentStep: Int) -> Color {
        if currentStep > step {
            return .green
        } else if currentStep == step {
            return .accentColor
        } else {
            return .gray
        }
    }
    
    func goToStep(_ step: Int, with proxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.75)) {
            project.currentStep = step
            proxy.scrollTo(stepIds[step], anchor: .top)
            print("went to step", project.currentStep)
        }
        
    }
    
    // Function to handle text change
    func fetchAlbum(scrollViewProxy: ScrollViewProxy) {
        let setProgress = setProgressAnimated(progress: $fetchProgress, label: $fetchProgressLabel)
        fetchAlbumArtVideo(from: albumURL, setProgress: setProgress) { fileURL in
            project.rawVideoFileURL = fileURL
            setProgress(100, "Album Art Downloaded.")
            goToStep(2, with: scrollViewProxy)
        }
    }
}

import SwiftData

struct ProjectViewPreview: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    var body: some View {
        ProjectView(project: projects.first!)
            .onAppear {
                printDocumentDirectoryPath()
            }
    }
}

#Preview {
    ProjectViewPreview()
        .modelContainer(previewContainer)
}
