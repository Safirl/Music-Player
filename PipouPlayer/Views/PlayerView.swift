//
//  PlayerView.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct PlayerView: View {
    @State private var isFavorite: Bool = true
    var currentSong: Song
    @Environment(\.presentationMode) var presentationMode
    @StateObject var audioManager = AudioManager.shared
    
    var dragToDismissGesture: some Gesture {
        DragGesture()
            .onEnded { gesture in
                if gesture.translation.height > 100 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
    var body: some View {
        ZStack(alignment: .top){
            currentSong.image
                .resizable()
                .blur(radius: 30)
                .frame(width: 600, height: UIScreen.screenHeight*1.05)
                .clipped()
                .mask(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]), startPoint: .bottom, endPoint: .top))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            
            VStack{
                Spacer()
                Button(action: {
                    // Dismiss the PlayerView
                    presentationMode.wrappedValue.dismiss()
                }) {
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .frame(width: 88, height: 4)
                        .opacity(0.5)
                        .padding(.top, UIScreen.screenHeight*0.1)
                }.foregroundColor(.primary)
                
                Spacer()
                
                ZStack {
                    currentSong.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 330, height: 330)
                        .clipped()
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    HStack {
                        Spacer()
//                        VStack {
//                            Spacer()
//                            FavoriteButton(isSet: $isFavorite, size:42)
//                                .padding(.bottom, 26)
//                                .padding(.trailing, 16)
//                        }
                    }
                    .padding(.horizontal, 10.0)
                }.scaledToFit()
                
                Spacer()
                
                VStack {
                    Text(currentSong.title)
                        .bold()
                    Text(currentSong.artistName)
                    MusicSlider(audioManager: AudioManager.shared)
                        .frame(width: 326)
                        .padding(.top, 26)
                    MusicPlayer(song: currentSong)
                        .padding(.top, 18)
                }
                // Push content to the top
                Spacer()
                
                HStack {
                    Spacer()
                    // Push image to the right
                    Image("waitlistIcon")
                        .frame(width: 38, height: 38)
                        .padding([.trailing, .bottom], 20) // Add padding to position the image
                }
            }
            .padding(.horizontal)
            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight) // Ensure VStack takes full width and height
        }
        .gesture(dragToDismissGesture)
    }
}

#Preview {
    let songs = ModelData().songs
    return Group {
        PlayerView(currentSong: songs[0])
    }
}
