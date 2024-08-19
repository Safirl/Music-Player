//
//  FavoriteButton.swift
//  PipouPlayer
//
//  Created by loic leforestier on 04/07/2024.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet: Bool
    @Environment(ModelData.self) var modelData // Accès à l'environnement partagé ModelData
    var song: Song
    var size: CGFloat // Taille du bouton

    var body: some View {
        Button(action: {
            isSet.toggle()
//            modelData.updateFavoriteStatus(for: song, isFavorite: isSet)
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5)
                
                Image(systemName: isSet ? "heart.fill" : "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(isSet ? Color(red: 1, green: 0.44, blue: 0.44) : .gray)
                    .padding(size * 0.25) // Taille de l'icône relative à la taille du bouton
            }
            .frame(width: size, height: size) // Taille globale du bouton
        }
    }
}

#Preview {
    let songs = ModelData().songs
    @State var isFavorite = ModelData().songs[0].isFavorite
    return Group
    {
        FavoriteButton(isSet: $isFavorite, song: songs[0], size: 64)
            .environment(ModelData())
    }
}
