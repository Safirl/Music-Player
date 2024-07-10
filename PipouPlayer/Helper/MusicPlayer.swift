//
//  MusicController.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

struct MusicPlayer: View {
    var song: Song
    @StateObject var audioManager = AudioManager.shared
    
    var body: some View {
        HStack(spacing: 22){
            Button(action: {
                // Action pour le bouton "previous"
                print("Previous button tapped")
            }) {
                Image("previousIcon")
                    .resizable()
                    .frame(width: 38, height: 38)
            }
            
            Button(action: {
                // Action pour le bouton "pause"
                print(song.fileName)
                if(!audioManager.isPlaying){
                    audioManager.playAudio(fileName: song.fileName)
                }else {audioManager.stopAudio()}
            }) {
                Image(audioManager.isPlaying ? "pauseIcon" : "playIcon")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            Button(action: {
                // Action pour le bouton "next"
                print("Next button tapped")
            }) {
                Image("nextIcon")
                    .resizable()
                    .frame(width: 38, height: 38)
            }
        }
    }
}

#Preview {
    let songs = ModelData().songs
    return Group
    {
        MusicPlayer(song: songs[0])
    }
    
}
