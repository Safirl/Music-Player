//
//  MusicController.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

struct MusicController: View {
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
                print("Pause button tapped")
            }) {
                Image("pauseIcon")
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
    MusicController()
}
