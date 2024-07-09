//
//  SongRow.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

struct SongRow: View {
    
    @State private var isFavorite: Bool
    var song: Song
    
    init(song: Song) {
            self.song = song
            self._isFavorite = State(initialValue: song.isFavorite)
        }
    
    var body: some View {
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
            
            FavoriteButton(isSet: $isFavorite, size:32)
                .padding(.trailing, 14.0)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    let songs = ModelData().songs
    return Group
    {
        SongRow(song: songs[2])
        SongRow(song: songs[0])
        SongRow(song: songs[1])
    }
    
}
