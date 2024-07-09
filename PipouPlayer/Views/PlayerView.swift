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
    
    var body: some View {
        
        ZStack(alignment: .top){
            Image("driftingSmoke")
                .resizable()
                .blur(radius: 30)
                .frame(width: 600, height: UIScreen.screenHeight*1.05)
                .clipped()
                .mask(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]), startPoint: .bottom, endPoint: .top))
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight*1.5)
                )
            
            VStack{
                Spacer()
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .frame(width: 88, height: 4)
                    .opacity(0.5)
                    .padding(.top, UIScreen.screenHeight*0.1)
                
                Spacer()
                
                ZStack {
                    Image("driftingSmoke")
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                FavoriteButton(isSet: $isFavorite, size:42)
                                    .padding(.bottom, 26)
                                    .padding(.trailing, 16)
                            }
                        }
                        .padding(.horizontal, 10.0)
                    }
                }.scaledToFit()
                
                Spacer()
                
                VStack {
                    Text("Drifting Smoke")
                        .bold()
                    Text("Kalaido - Lo-fi Music")
                    MusicSlider()
                        .frame(width: 326)
                        .padding(.top, 26)
                    MusicController()
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
    }
}

#Preview {
    PlayerView()
}
