//
//  ContentView.swift
//  LiveArt
//
//  Created by GeoWat on 2024/2/27.
//

import SwiftUI
import SwiftData
import TipKit

struct NewProjectTip: Tip {
    var title: Text {
        Text("Create a new project")
            .foregroundStyle(.indigo)
    }
    
    var message: Text? {
        Text("Let's start the demo by creating a new project.")
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    @State private var shouldPlay = false
    @State private var isShowingShareSheet = false
    @State private var showingActionSheet = false
    @State private var presentedProjects: [Project] = []
    @State private var showGuide = false
    @State private var showNewProjectTip = false
    @State private var isDeleting = false
    @State private var isConfirmDeleting = false
        
    var body: some View {
        NavigationStack(path: $presentedProjects) {
            VStack {
                HStack(alignment: .center, spacing: 10) {
                    Text("LiveArt")
                        .fontDesign(.serif)
                        .font(.largeTitle)
                        
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                Button(action: {
                    self.showingActionSheet = true
                }) {
                    HStack {
                        VStack {
                            Image(systemName: "plus") // System plus icon
                            Text("New Project")
                                .fontDesign(.monospaced)
                        }
                        .fontWeight(.bold)
                    }
                    .foregroundColor(.black) // Set the text and icon color
                    .padding(.vertical, 30) // Padding inside the button for the text and icon
                    .frame(maxWidth: .infinity) // Take up all available width
                    .background(
                        // Background image with a rounded rectangle overlay for rounded corners
                        Image("PhotoFlyOut")
                            .resizable()
                            .scaledToFill()
                            .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.5)))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20)) // Rounded corners
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Choose Project Type"), message: Text("Choose your Live Photo's video source. You can select a live album art from Apple Music or a video from your Photos library."), buttons: [
                        .cancel(),
                        .default(Text("Create Live Album Art")) {
                            let newAlbumProject = Project(name: "New Project", type: .LiveAlbum)
                            modelContext.insert(newAlbumProject)
                            presentedProjects.append(newAlbumProject)
                        },
                        .default(Text("Create Live Photo from Video")) {
                            let newVideoProject = Project(name: "New Project", type: .UploadedVideo)
                            modelContext.insert(newVideoProject)
                            presentedProjects.append(newVideoProject)
                        },
                    ])
                }
                .padding(.horizontal) // Padding to the edges of the screen
                .padding(.bottom, 10)
                if showNewProjectTip {
                    TipView(NewProjectTip(), arrowEdge: .top)
                        .padding()
                }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("Projects")
                        .fontDesign(.monospaced)
                        .font(.title) // Makes the text larger
                        .fontWeight(.bold) // Makes the text bolder
                    Text("\(projects.count)")
                        .fontDesign(.rounded)
                    Spacer()
                    Button(isDeleting ? "Cancel" : "Edit") {
                        withAnimation {
                            isDeleting.toggle()
                        }
                        
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Aligns HStack to the left
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem](repeating: .init(.flexible(), spacing: 20), count: 3), spacing: 20) {
                        ForEach(projects) { project in
                            VStack {
                                Group {
                                    if let imgURL = project.coverPhoto {
                                        AsyncImage(url: imgURL) { image in
                                            image
                                                .resizable()
                                        } placeholder: {
                                            Image("project_placeholder")
                                                .resizable()
                                        }
                                        .scaledToFill()
                                        .aspectRatio(9/16, contentMode: .fill)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(20)
                                    } else {
                                        Image("project_placeholder")
                                            .resizable()
                                            .scaledToFill()
                                            .aspectRatio(9/16, contentMode: .fill)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .clipped()
                                            .cornerRadius(20)
                                    }
                                }
                                .overlay(
                                    isDeleting ? ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.7))
                                        Image(systemName: "trash.circle.fill")
                                            .font(.largeTitle)
                                            .foregroundStyle(.red)
                                            .backgroundStyle(.white)
                                            .shadow(radius: 10)
                                    } : nil
                                )
                                .overlay(
                                    !isDeleting && project.workInProgress ? ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.black.opacity(0.5))
                                        Text("Work In Progress")
                                            .foregroundColor(.white)
                                            .fontDesign(.monospaced)
                                            .fontWeight(.bold)
                                    } : nil
                                )
                                .onTapGesture {
                                    if isDeleting {
                                        isConfirmDeleting.toggle()
                                    } else {
                                        presentedProjects.append(project)
                                    }
                                }
                                .alert("Are you sure?", isPresented: $isConfirmDeleting) {
                                    Button("Cancel", role: .cancel) {}
                                    Button("Delete", role: .destructive) {
                                        withAnimation {
                                            modelContext.delete(project)
                                        }
                                        
                                    }
                                }
                                Text(project.creationDate)
                                    .font(.caption)
                                Text(project.name)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationDestination(for: Project.self) { project in
                switch project.type {
                case .LiveAlbum:
                    ProjectView(project: project)
                case .UploadedVideo:
                    ProjectUploadedVideoView(project: project)
                }
            }
        }
        .sheet(isPresented: $showGuide, onDismiss: {
            showNewProjectTip = true
        }) {
            GuideView(show: $showGuide)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
