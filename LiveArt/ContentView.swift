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
        Text("Let's start the demo by tapping this button to create a new project. Note: The option to create from a library video is under development; for now, it will guide you through creating from an album art.")
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    

    @StateObject private var viewModel = ViewModel()
    @State private var shouldPlay = false
    @State private var isShowingShareSheet = false
    @State private var showingActionSheet = false
    @State private var presentedProjects: [ProjectModel] = []
    @State private var showNewUserGuide = true
    @State private var showNewProjectTip = false
        
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
                            let newAlbumProject = ProjectModel(name: "New Project", type: .LiveAlbum, creationDate: todayDate, coverPhoto: nil, currentStep: 1, workInProgress: true, livePhoto: nil)
                            viewModel.projects.append(newAlbumProject)
                            presentedProjects.append(newAlbumProject)
                        },
                        .default(Text("WIP: Create Live Photo from Video")) {
                            let newVideoProject = ProjectModel(name: "New Project", type: .LiveAlbum, creationDate: todayDate, coverPhoto: nil, currentStep: 1, workInProgress: true, livePhoto: nil)
                            viewModel.projects.append(newVideoProject)
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
                    Text("\(viewModel.projects.count)")
                        .fontDesign(.rounded)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Aligns HStack to the left
                .padding(.leading)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem](repeating: .init(.flexible(), spacing: 20), count: 3), spacing: 20) {
                        ForEach(viewModel.projects) { project in
                            VStack {
                                Group {
                                    if let lp = project.livePhoto {
                                        LivePhotoViewRep(livePhoto: lp.livePhoto, shouldPlay: $shouldPlay, repetitivePlay: true)
                                            .aspectRatio(9/16, contentMode: .fill)
                                            .cornerRadius(20)
                                    } else {
                                        Image(project.coverPhoto ?? "project_placeholder")
                                            .resizable()
                                            .scaledToFill()
                                            .aspectRatio(9/16, contentMode: .fill)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .clipped()
                                            .cornerRadius(20)
                                    }
                                }
                                .overlay(
                                    project.workInProgress ?
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.5))
                                            Text("Work In Progress")
                                                .foregroundColor(.white)
                                                .fontDesign(.monospaced)
                                                .fontWeight(.bold)
                                        }
                                        : nil
                                )
                                .onTapGesture {
                                    presentedProjects.append(project)
                                    print(project)
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
            .navigationDestination(for: ProjectModel.self) { project in
                ProjectView(projectId: project.id, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showNewUserGuide, onDismiss: {
            showNewProjectTip = true
        }) {
            NewUserGuideView(show: $showNewUserGuide)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
