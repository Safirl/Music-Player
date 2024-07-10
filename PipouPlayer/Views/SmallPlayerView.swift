//
//  SmallPlayerView.swift
//  PipouPlayer
//
//  Created by loic leforestier on 09/07/2024.
//

import SwiftUI

struct SmallPlayerView: View {
    var song: Song
    @State private var showMusicPlayer = false
    @StateObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var dragToOpenGesture: some Gesture {
        DragGesture()
            .onEnded { gesture in
                if gesture.translation.height < -50 {
                    showMusicPlayer = true
                }
            }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: UIScreen.screenWidth, height: 110)
                .cornerRadius(25, corners: [.topLeft, .topRight])
            song.image
                .resizable()
                .opacity(0.8)
                .blur(radius: 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .mask(
                    Rectangle()
                        .frame(width: UIScreen.screenWidth, height: 110)
                        .cornerRadius(25, corners: [.topLeft, .topRight])
                )
            Button(action: {
                showMusicPlayer = true
            }) {
                RoundedRectangle(cornerRadius: 25)
                    .frame(width: 88, height: 4)
                    .opacity(0.5)
                    .padding(.bottom, UIScreen.screenHeight*0.1)
                    .fullScreenCover(isPresented: $showMusicPlayer) {
                        PlayerView(song: song)
                    }
            }.foregroundColor(.primary)
            HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text(song.title)
                        .fontWeight(.semibold)
                    Text(song.artistName)
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                Button(action: {
                    // Action pour le bouton "pause"
                    print(song.fileName)
                    if(!audioManager.isPlaying){
                        audioManager.playAudio(fileName: song.fileName)
                    }else {audioManager.stopAudio()}
                }) {
                    Image(audioManager.isPlaying ? "pauseIcon" : "playIcon")
                        .resizable()
                        .frame(width: 38, height: 38)
                }
                
                Button(action: {
                    // Action pour le bouton "next"
                    print("Next button tapped")
                }) {
                    Image("nextIcon")
                        .resizable()
                        .frame(width: 38, height: 38)
                }.padding(.leading, 18)
            }.padding(.horizontal, 30)
            
        }
        .gesture(dragToOpenGesture)
        .frame(width: UIScreen.screenWidth, height: 110)
    }
}

#Preview {
    let songs = ModelData().songs
    return Group{
        SmallPlayerView(song: songs[1])
    }
}
