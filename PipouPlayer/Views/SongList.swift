//
//  SongList.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct SongList: View {
    
    @Environment (ModelData.self) var modelData
    @State private var showFavorites : Bool = true
    @StateObject var audioManager = AudioManager.shared
    @State private var showAddMusicView = false
    
    var filteredSongs : [Song] {
        modelData.songs.filter { song in
            (showFavorites && song.isFavorite)
        }
    }
    
    var currentSong: Song
    
    var body: some View {
        ZStack {
            VStack {
                VStack{
                    HStack(alignment: .center) {
                        Text("Music Player")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            showAddMusicView = true
                        }){
                            Image("addIcon")
                                .frame(width: 38, height: 38)
                        }
                    }
                    ScrollView{
                        HStack(alignment: .center, spacing: 12) {
                            Text("Vos favoris")
                                .font(.title)
                                .fontWeight(.semibold)
                            Button(action: {
                                // Action pour le bouton
                                showFavorites.toggle()
                            }) {
                                Image(showFavorites ? "downArrowIcon" : "upArrowIcon")
                                    .frame(width: 19, height: 9.5)
                            }
                            Spacer()
                        }
                        
                        VStack{
                            ForEach(filteredSongs) { song in
                                SongRow(song: song)
                            }
                        }
                        
                        HStack(alignment: .center, spacing: 12) {
                            Text("Vos musiques")
                                .font(.title)
                                .fontWeight(.semibold)
                            Spacer()
                        }.padding(.top, 28)
                        
                        VStack{
                            ForEach(modelData.songs) { song in
                                SongRow(song: song)
                            }
                        }
                    }
                    
                }.padding(.horizontal, 30)
                
                Spacer()
                if modelData.songs.isEmpty {
                    SmallPlayerView(song: currentSong)
                }
                else {
                    SmallPlayerView(song: modelData.songs[audioManager.currentSongIndex])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear {
                AudioManager.shared.initializeModelData(modelData: modelData)
        }
            if showAddMusicView {
                AddMusicView(showAddMusicView: $showAddMusicView)
                    .zIndex(1)
            }
        }
        
    }
        
}

#Preview {
    let songs = ModelData().songs
    return Group {
        SongList(currentSong: songs[0])
            .environment(ModelData())
    }
}
