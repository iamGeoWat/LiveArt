//
//  NewUserGuideView.swift
//  makeit
//
//  Created by GeoWat on 2024/2/24.
//

import SwiftUI

struct GuideView: View {
    @State private var page: Int = 0
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            if page == 0 {
                Group {
                    Text("Welcome to LiveArt!")
                        .font(.largeTitle)
                        .fontDesign(.serif)
                    VStack(spacing: 30) {
                        VStack(alignment: .listRowSeparatorLeading) {
                            HStack {
                                Image(systemName: "photo.stack")
                                    .padding()
                                Text("Ever loved Apple Music's animated album arts?")
                                
                            }
                            HStack {
                                Image(systemName: "livephoto")
                                    .padding()
                                Text("LiveArt transforms your favorite Apple Music album art or selected videos into captivating Live Photos and Wallpapers!")
                            }
                        }
                        HStack {
                            Spacer()
                            Image("apple_music")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                .shadow(radius: 10)
                            Spacer()
                            Image(systemName: "arrowshape.forward.circle.fill")
                            Spacer()
                            Image("lock_screen")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Spacer()
                        }
                        Spacer()
                        GuideButtonView(page: $page, show: $show)
                    }
                }
                .transition(.blurReplace)
            } else if page == 1 {
                Group {
                    Text("How it works")
                        .font(.largeTitle)
                        .fontDesign(.serif)
                    VStack(spacing: 30) {
                        ScrollView {
                            VStack(alignment: .listRowSeparatorLeading) {
                                HStack {
                                    Image(systemName: "applescript")
                                        .padding()
                                    Text("LiveArt has a script using an **HTML Parser** to retrieve animated album arts from Apple Music. ***In this offline demo, we will use local resources.***")
                                    
                                }
                                HStack {
                                    Image(systemName: "video.badge.waveform")
                                        .padding()
                                    Text("Then, a metadata multiplexer that aligns with iOS's AI-driven motion analysis to ensure the exported Live Photos meet wallpaper standards.")
                                }
                                HStack {
                                    Image(systemName: "livephoto")
                                        .padding()
                                    Text("Finally, it incorporates a transcoding engine built on **AVFoundation** and an image extractor to assemble Live Photo assets.")
                                }
                            }
                            Image("downloader_code")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                .shadow(radius: 10)
                        }
                        GuideButtonView(page: $page, show: $show)
                    }
                }
                .transition(.blurReplace)
            } else if page == 2 {
                Group {
                    VStack {
                        Text("Secret sauce")
                            .font(.largeTitle)
                            .fontDesign(.serif)
                        Text("How to bypass Apple's motion check?")
                            .font(.subheadline)
                            .fontDesign(.serif)
                    }
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 30) {
                        ScrollView {
                            VStack(alignment: .listRowSeparatorLeading, spacing: 20) {
                                HStack {
                                    Image(systemName: "lock")
                                        .padding()
                                    Text("Starting with iOS 17, Live Photo will must undergo a motion check before being used as Live Wallpapers. This invalidated many Live Photo creator apps :(")
                                }
                                Image("motion_check")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                                    .shadow(radius: 10)
                                    .frame(maxWidth: 200)
                                HStack {
                                    Image(systemName: "lightbulb.min")
                                        .padding()
                                    Text("No solutions were readily available online, but the metadata from a functional Live Wallpaper caught my eye:")
                                }
                                HStack {
                                    Image(systemName: "list.dash.header.rectangle")
                                        .padding()
                                    VStack {
                                        
                                        Text("Live Photo Info: 3 0.0145119996741414 1844164067 128 86.7509384155273 14.2610721588135 0.396545708179474 -0.0815095826983452 1.92900002002716 4 4 0 -1 0 0 0 0 0 0 0 0 0 9.80908925027372e-45 0.264391481876373 3209850598 10779 50282")
                                            .fontDesign(.monospaced)
                                            .font(.caption2)
                                    }
                                }
                                HStack {
                                    Image(systemName: "lightbulb.max")
                                        .padding()
                                    Text("It looks like a feature vector for machine learning, embedded as timed metadata in Live Photos. The Photos App seems to use a machine learning algorithm to assess whether a photo is **suitable** for wallpaper. Limit the choice of users for a consistent experience, very Apple :)")
                                }
                                
                                HStack {
                                    Image(systemName: "lock.open")
                                        .padding()
                                    Text("This led to my solution: muxing the metadata from a functional Live Wallpaper with ours. As a result, the interpolated Live Photo is very likely to pass the motion check.")
                                }
                            }
                            Image("metadata_code")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                .shadow(radius: 10)
                        }
                        GuideButtonView(page: $page, show: $show)
                    }
                }
                .transition(.blurReplace)
            } else if page == 3 {
                Group {
                    VStack {
                        Text("Future Plans")
                            .font(.largeTitle)
                            .fontDesign(.serif)
                    }
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 30) {
                        ScrollView {
                            VStack(alignment: .listRowSeparatorLeading, spacing: 20) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                        .padding()
                                    Text("Enable users to create Live Photos from their selected videos using SwiftUI's **PhotosPicker**.")
                                }
                                HStack {
                                    Image(systemName: "crop.rotate")
                                        .padding()
                                    Text("Offer various styles for the output wallpapers, beyond simple center cropping.")
                                }
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .padding()
                                    Text("With no submission size limit for the Swift Student Challenge, users can create higher quality wallpapers using 4K assets.")
                                }
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .padding()
                                    Text("Integrate this app into Apple Music's share Actionsheet, eliminating the need for users to manually copy and paste album URLs into my app.")
                                }
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .padding()
                                    Text("***Release on App Store!***")
                                }
                            }
                        }
                        GuideButtonView(page: $page, show: $show)
                    }
                }
                .transition(.blurReplace)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 50)
    }
}

struct GuideButtonView: View {
    @Binding var page: Int
    @Binding var show: Bool
    var btnText = ["See how it works", "Next", "Next", "Done"]

    var body: some View {
        Button(action: {
            withAnimation {
                if page == btnText.count - 1 {
                    show = false
                } else {
                    page += 1
                }
            }
        }, label: {
            Text(btnText[page])
                .frame(maxWidth: .infinity)
        })
        .tint(.blue)
        .buttonStyle(BorderedProminentButtonStyle())
        .controlSize(.large)
    }
}

struct GuideViewPreview: View {
    @State private var show = false
    
    var body: some View {
        GuideView(show: $show)
    }
}

#Preview {
    GuideViewPreview()
}
