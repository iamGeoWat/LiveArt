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
    var project: Project
    
    
    @State private var albumURL: String = "https://music.apple.com/us/playlist/me-and-bae/pl.a13aca4f4f2c45538472de9014057cc0"
    @State private var timer: Timer?
    @State private var shouldPlayLPPreview = false
    @State private var shouldPlayLWPreview = false
    @State private var isShowingShareSheet = false
    @State private var isShowingLPSaved = false
    @State private var isShowingLWSaved = false
    @State private var isShowingInvokeFailed = false
    @State private var generateProgress = 0.0
    @State private var generateProgressLabel = "Ready"

    @State private var fetchProgress = 0.0
    @State private var fetchProgressLabel = "Ready"
        
//    private var project: Project {
//        return viewModel.projects.first(where: { $0.id == projectId })!
//    }
    
    let stepIds: [UUID] = (1...8).map { _ in UUID() }
    let fetchStates = ["Loading HTML", "Looking for video tag", "Downloading M3U8 file", "Done"]
    
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
                            Text("Open a playlist or album in Apple Music → Top-right menu → Share → Copy")
                                .padding(.bottom, 10)
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
                            Text("We'll employ AVFoundation and ImageIO APIs to convert the downloaded MP4 file into a Live Photo and Live Wallpaper that meets specifications.")
                            HStack {
                                Button("Generate") {
                                    withAnimation {
                                        generateProgressLabel = "processing live photo..."
                                    }
                                    generateLivePhoto() {
                                        generateLiveWallpaper() {
                                            print("goto step 3")
                                            goToStep(3, with: proxy)
                                        }
                                    }
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
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
                            paddedAnchor(forStep: 3)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .opacity(project.currentStep != 2 ? 0.5: 1.0)
                        .disabled(project.currentStep != 2)
                    }
                    // Step 3
                    HStack(alignment: .top) {
                        VStack(spacing: 2) {
                            Image(systemName: "circle.fill")
                                .imageScale(.medium)
                                .font(.footnote)
                            Rectangle()
                                .frame(width: 2)
                                .clipped()
                        }
                        .foregroundColor(colorForStep(3, when: project.currentStep))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step 3:")
                                .font(.footnote)
                            Text("Preview and Save Live Photo")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text("This is a Live Photo plays at the normal speed. You can skip it if you only want the animated wallpaper.")
                                .padding(.bottom, 10)
                            if let lp = project.livePhoto?.livePhoto {
                                LivePhotoViewRep(livePhoto: lp, shouldPlay: $shouldPlayLPPreview, repetitivePlay: false)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(minWidth: 0, maxWidth: 220, maxHeight: 220)
                                    .clipped()
                                    .cornerRadius(20)
                                    .padding(.bottom, 10)
                            } else {
                                Rectangle()
                                    .scaledToFill()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: 220)
                                    .clipped()
                                    .cornerRadius(20)
                                    .padding(.bottom, 10)
                                    .overlay(
                                        Image(systemName: "photo.fill") // Use an SF Symbol
                                            .font(.largeTitle) // Set the symbol's size
                                            .foregroundColor(.white), // Set the symbol's color
                                        alignment: .center // Ensure the symbol is centered within the rectangle
                                    )
                            }
                            HStack {
                                Button("Play") {
                                    shouldPlayLPPreview.toggle()
                                    print("playing")
                                }
                                .buttonStyle(BorderedButtonStyle())
                                Button("Save") {
                                    guard let lp = project.livePhoto else {
                                        print("live photo not in project")
                                        return
                                    }
                                    saveLivePhotoToLibrary(pairedImage: lp.pairedImage, pairedVideo: lp.pairedVideo) 
                                    print("saving")
                                    isShowingLPSaved = true
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                                .alert("Live Photo Saved", isPresented: $isShowingLPSaved) {
                                    Button("OK", role: .cancel) {
                                        goToStep(4, with: proxy)
                                    }
                                }
                                Button("Skip") {
                                    goToStep(4, with: proxy)
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                                Spacer()
                            }
                            paddedAnchor(forStep: 4)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .opacity(project.currentStep != 3 ? 0.5: 1.0)
                        .disabled(project.currentStep != 3)
                    }
                    // Step 4
                    HStack(alignment: .top) {
                        VStack(spacing: 2) {
                            Image(systemName: "circle.fill")
                                .imageScale(.medium)
                                .font(.footnote)
                            Rectangle()
                                .frame(width: 2)
                                .clipped()
                        }
                        .foregroundColor(colorForStep(4, when: project.currentStep))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step 4:")
                                .font(.footnote)
                            Text("Preview and Save Live Wallpaper")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text("This Live Photo has been sped up and had its metadata multiplexed to meet Live Wallpaper standards, making it likely to be accepted by iOS as a Live Wallpaper.")
                                .padding(.bottom, 10)
                            if let lp = project.liveWallpaper?.livePhoto {
                                LivePhotoViewRep(livePhoto: lp, shouldPlay: $shouldPlayLWPreview, repetitivePlay: false)
                                    .aspectRatio(9/16, contentMode: .fit)
                                    .frame(minWidth: 0, maxWidth: 220)
                                    .clipped()
                                    .cornerRadius(20)
                                    .padding(.bottom, 10)
                            } else {
                                Rectangle()
                                    .scaledToFill()
                                    .aspectRatio(9/16, contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: 220)
                                    .clipped()
                                    .cornerRadius(20)
                                    .padding(.bottom, 10)
                                    .overlay(
                                        Image(systemName: "photo.fill") // Use an SF Symbol
                                            .font(.largeTitle) // Set the symbol's size
                                            .foregroundColor(.white), // Set the symbol's color
                                        alignment: .center // Ensure the symbol is centered within the rectangle
                                    )
                            }
                            HStack {
                                Button("Play") {
                                    shouldPlayLWPreview.toggle()
                                    print("playing")
                                }
                                .buttonStyle(BorderedButtonStyle())
                                Button("Save") {
                                    guard let liveWallpaper = project.liveWallpaper else {
                                        print("Live wallpaper not in project")
                                        return
                                    }
                                    saveLivePhotoToLibrary(pairedImage: liveWallpaper.pairedImage, pairedVideo: liveWallpaper.pairedVideo)
                                    isShowingLWSaved = true
                                    print("saving")
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                                .alert("Live Wallpaper Saved", isPresented: $isShowingLWSaved) {
                                    Button("OK", role: .cancel) {
                                        goToStep(5, with: proxy)
                                    }
                                }
                                Button("Skip") {
                                    goToStep(5, with: proxy)
                                    print("go next")
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                                Spacer()
                            }
                            paddedAnchor(forStep: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .opacity(project.currentStep != 4 ? 0.5: 1.0)
                        .disabled(project.currentStep != 4)
                    }
                    // Step 5
                    HStack(alignment: .top) {
                        VStack(spacing: 2) {
                            Image(systemName: "circle.fill")
                                .imageScale(.medium)
                                .font(.footnote)
                            Rectangle()
                                .frame(width: 2)
                                .clipped()
                        }
                        .foregroundColor(colorForStep(5, when: project.currentStep))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step 5:")
                                .font(.footnote)
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
                                Button("Finish") {
                                    print("go next")
                                    goToStep(6, with: proxy)
                                    project.workInProgress = false
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                                Spacer()
                            }
                            paddedAnchor(forStep: 6)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .opacity(project.currentStep != 5 ? 0.5: 1.0)
                        .disabled(project.currentStep != 5)
                    }
                    // Finished
                    Group {
                        HStack(alignment: .top) {
                            VStack(spacing: 2) {
                                Image(systemName: "circle.fill")
                                    .imageScale(.medium)
                                    .font(.footnote)
                            }
                            .foregroundColor(colorForStep(6, when: project.currentStep))
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
                        .id(stepIds[6])
                        // Project Result
                        Text("View your result")
                            .font(.largeTitle)
                            .fontDesign(.monospaced)
                            .padding(.bottom, 30)
                        VStack {
                            VStack {
                                ResultView(project: project)
                            }
                            .frame(maxWidth: 500)
                            Spacer()
                        }
                    }
                    .opacity(project.currentStep != 6 ? 0.5: 1.0)
                    .disabled(project.currentStep != 6)
                }
                .padding(.horizontal)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            goToStep(project.currentStep, with: proxy)
                        }
                    }
                }
                .frame(maxWidth: 600)
                
            }
        }
    }
    
    func generateLivePhoto(completion: @escaping () -> Void) {
        guard let rawVideoFileURL = project.rawVideoFileURL else {
            print("no video file")
            completion()
            return
        }
        transcodeLive("Photo", for: rawVideoFileURL, progress: $generateProgress, progressLabel: $generateProgressLabel) { result in
            switch result {
            case .success(let urls):
                let videoURL = urls[0]
                let photoURL = urls[1]
                print("gen succeeded")
                generateProgressLabel = "Generating Live Photo..."
                PHLivePhoto.request(withResourceFileURLs: [photoURL, videoURL], placeholderImage: nil, targetSize: CGSize.zero, contentMode: PHImageContentMode.aspectFit, resultHandler: { (livePhoto: PHLivePhoto?, info: [AnyHashable : Any]) -> Void in
                    if let isDegraded = info[PHLivePhotoInfoIsDegradedKey] as? Bool, isDegraded {
                        return
                    }
                    guard let livePhoto = livePhoto else {
                        return
                    }
                    withAnimation {
                        project.livePhoto = LivePhoto(pairedImage: photoURL, pairedVideo: videoURL, livePhoto: livePhoto)
                        generateProgressLabel = "Live Photo generated..."
                        generateProgress = 50
                        completion()
                    }
                })
            default:
                print("gen lp failed")
            }
        }
    }
    
    func generateLiveWallpaper(completion: @escaping () -> Void) {
        guard let rawVideoFileURL = project.rawVideoFileURL else {
            print("no video file")
            completion()
            return
        }
        transcodeLive("Wallpaper", for: rawVideoFileURL, progress: $generateProgress, progressLabel: $generateProgressLabel) { result in
            switch result {
            case .success(let urls):
                let videoURL = urls[0]
                let photoURL = urls[1]
                print("gen succeeded")
                generateProgressLabel = "Generating Live Wallpaper..."
                PHLivePhoto.request(withResourceFileURLs: [photoURL, videoURL], placeholderImage: nil, targetSize: CGSize.zero, contentMode: PHImageContentMode.aspectFit, resultHandler: { (livePhoto: PHLivePhoto?, info: [AnyHashable : Any]) -> Void in
                    if let isDegraded = info[PHLivePhotoInfoIsDegradedKey] as? Bool, isDegraded {
                        return
                    }
                    guard let livePhoto = livePhoto else {
                        return
                    }
                    withAnimation {
                        project.liveWallpaper = LivePhoto(pairedImage: photoURL, pairedVideo: videoURL, livePhoto: livePhoto)
                        generateProgressLabel = "Live Wallpaper generated. Done."
                        generateProgress = 100
                        completion()
                    }
                })
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
        }
    }
    
    // Function to handle text change
    func fetchAlbum(scrollViewProxy: ScrollViewProxy) {
        fetchAlbumArtVideo(from: albumURL, progress: $fetchProgress, progressLabel: $fetchProgressLabel) { fileURL in
            withAnimation {
                fetchProgress = 100
                fetchProgressLabel = "Album Art Downloaded."
            }
            project.rawVideoFileURL = fileURL
        }
    }
}

struct ProjectViewPreview: View {
    var previewProject = Project(name: "speak_now", type: .LiveAlbum)
    static func printDocumentDirectoryPath() {
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Document Directory Path: \(path)")
        }
    }
    var body: some View {
        ProjectView(project: previewProject)
            .onAppear {
                ProjectViewPreview.printDocumentDirectoryPath()
            }
    }
}

#Preview {
    ProjectViewPreview()
}
