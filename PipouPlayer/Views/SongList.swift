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
    
    var filteredSongs : [Song] {
        modelData.songs.filter { song in
            (showFavorites && song.isFavorite)
        }
    }
    
    var body: some View {
        VStack {
            VStack{
                HStack(alignment: .center) {
                    Text("Music Player")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Spacer()
                    Image("addIcon")
                        .frame(width: 38, height: 38)
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
            
            SmallPlayerView(song: modelData.songs[1])
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .bottom)
        
    }
}

#Preview {
    SongList()
        .environment(ModelData())
}
