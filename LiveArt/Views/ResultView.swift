//
//  ResultView.swift
//  makeit
//
//  Created by GeoWat on 2024/2/22.
//

import SwiftUI
import Photos

struct ResultView: View {
    var project: Project

    @Namespace private var ns
    @State private var viewType = "LP"
    @State private var shouldPlay = false
    @State private var isShowingSaved = false
    
    
    var body: some View {
        // Project Result
        VStack(alignment: .center) {
            HStack {
                Group {
                    if let lp = viewType == "LP" ? project.livePhoto?.livePhoto : project.liveWallpaper?.livePhoto {
                        LivePhotoViewRep(livePhoto: lp, shouldPlay: $shouldPlay, repetitivePlay: false)
                                .aspectRatio(viewType == "LP" ? 1/1 : 9/16, contentMode: viewType == "LP" ? .fit : .fill)
                                .frame(maxWidth: 500)
                    } else {
                        Rectangle()
                            .fill(.gray)
                            .aspectRatio(viewType == "LP" ? 1/1 : 9/16, contentMode: viewType == "LP" ? .fit : .fill)
                            .frame(maxWidth: 500)
                            .overlay(
                                Image(systemName: "photo.fill") // Use an SF Symbol
                                    .font(.largeTitle) // Set the symbol's size
                                    .foregroundColor(.white), // Set the symbol's color
                                alignment: .center // Ensure the symbol is centered within the rectangle
                            )
                    }
                }
                
            }
            .overlay(alignment: .bottom) {
                HStack {
                    Spacer()
                    HStack {
                        Text("Live Photo")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color(.lightText))
                    }
                    .padding()
                    .background {
                        if viewType == "LP" {
                            Rectangle()
                                .fill(.clear)
                                .background(Material.thin)
                                .mask {
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                }
                                .opacity(0.8)
                                .matchedGeometryEffect(id: "ResultPhoto", in: ns)
                        }
                    }
                    .onTapGesture {
                        setViewType("LP")
                    }
                    Spacer()
                    HStack {
                        Text("Live Wallpaper")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color(.lightText))
                    }
                    .padding()
                    .background {
                        if viewType == "LW" {
                            Rectangle()
                                .fill(.clear)
                                .background(Material.thin)
                                .mask {
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                }
                                .opacity(0.8)
                                .matchedGeometryEffect(id: "ResultPhoto", in: ns)
                        }
                    }
                    .onTapGesture {
                        setViewType("LW")
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .clipped()
                .padding([.top, .bottom], 5)
                .background {
                    Rectangle()
                        .fill(.clear)
                        .background(Material.thin)
                        .mask {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                        }
                        .opacity(0.8)
                        .shadow(color: Color(.sRGBLinear, red: 0/255, green: 0/255, blue: 0/255).opacity(0.35), radius: 1, x: 0, y: 2)
                        .shadow(color: Color(.sRGBLinear, red: 255/255, green: 255/255, blue: 255/255).opacity(0.55), radius: 1, x: 0, y: -0.5)
                        
                }
                .padding()
            }
            .overlay(alignment: .topTrailing) {
                HStack {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 12, style: .circular)
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 55, height: 52)
                        Image(systemName: "livephoto.play")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color(.darkText))
                    }
                    .padding()
                    .onTapGesture {
                        if (viewType == "LP" ? project.livePhoto : project.liveWallpaper) != nil {
                            shouldPlay.toggle()
                        } else {
                            print("No Photo")
                        }
                    }
                    Spacer()
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 12, style: .circular)
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 55, height: 52)
                        Image(systemName: "square.and.arrow.down.on.square")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color(.darkText))
                    }
                    .padding()
                    .onTapGesture {
                        if let lp = viewType == "LP" ? project.livePhoto : project.liveWallpaper {
                            saveLivePhotoToLibrary(pairedImage: lp.pairedImage, pairedVideo: lp.pairedVideo)
                        } else {
                            print("No Photo")
                        }
                        isShowingSaved = true
                    }
                    .alert("Live \(viewType == "LP" ? "Photo" : "Wallpaper") Saved", isPresented: $isShowingSaved) {
                        Button("OK", role: .cancel) {}
                    }
                }
                
            }
            .mask {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
            }
            .shadow(color: Color(.sRGBLinear, red: 0/255, green: 0/255, blue: 0/255).opacity(0.15), radius: 18, x: 0, y: 14)
            Spacer()
        }
        .frame(maxHeight: 850)
    }
    
    func setViewType(_ newViewType: String) {
        withAnimation(.bouncy(duration: 0.3)) {
            viewType = newViewType
        }
    }
}

struct ResultViewPreview: View {
    var previewProject = Project(name: "speak_now", type: .LiveAlbum)
    static func printDocumentDirectoryPath() {
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Document Directory Path: \(path)")
        }
    }
    var body: some View {
        ResultView(project: previewProject)
    }
}

#Preview {
    ResultViewPreview()
}
