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
                    Button("hello") {
                        fetchAlbumArtVideo(from: "https://music.apple.com/us/playlist/me-and-bae/pl.a13aca4f4f2c45538472de9014057cc0") { videoFileURL in
                                print(videoFileURL)
                        }
                    }
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
    var btnText = ["Done"]

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
