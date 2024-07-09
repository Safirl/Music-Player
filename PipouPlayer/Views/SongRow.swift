//
//  SongRow.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

struct SongRow: View {
    @State private var isFavorite: Bool = true
    var songImage: Image
    
    var body: some View {
        HStack{
            songImage
                .resizable()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading){
                Text("Drifting Smoke")
                Text("Kalaido - Lo-fi Music")
            }
            
            Spacer()
            
            FavoriteButton(isSet: $isFavorite, size:32)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    SongRow(songImage: Image("driftingSmoke"))
}
