//
//  SongRow.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

struct SongRow: View {
    @Environment(ModelData.self) var modelData
    var isFavoriteBinding: Binding<Bool> {
            Binding<Bool>(
                get: { self.modelData.songs.first(where: { $0.id == song.id })?.isFavorite ?? false },
                set: { newValue in
                    if let index = self.modelData.songs.firstIndex(where: { $0.id == song.id }) {
                        self.modelData.songs[index].isFavorite = newValue
                        self.modelData.updateFavoriteStatus(for: song, isFavorite: newValue) // Mettre à jour le modèle
                    }
                }
            )
        }
    @StateObject var audioManager = AudioManager.shared
    var song: Song
    
    var body: some View {
        Button(action: {
            audioManager.playNewAudio(fileName: song.fileName)
        }) {
            HStack{
                song.image
                    .resizable()
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading){
                    Text(song.title)
                    Text(song.artistName)
                        .foregroundColor(Color(red: 0.31, green: 0.31, blue: 0.31))
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                FavoriteButton(isSet: isFavoriteBinding, song: song, size:32)
                    .padding(.trailing, 14.0)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundColor(.primary)
        }
    }
}

#Preview {
    let songs = ModelData().songs
    return Group
    {
        SongRow(song: songs[0])
        SongRow(song: songs[0])
        SongRow(song: songs[1])
    }
    .environment(ModelData())
    
}
