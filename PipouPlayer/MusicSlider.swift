//
//  Slider.swift
//  PipouPlayer
//
//  Created by loic leforestier on 05/07/2024.
//

import SwiftUI

struct MusicSlider: View {
    @State private var sliderValue: Double = 5
    
    var body: some View {
        VStack {
            // Custom track and thumb
            GeometryReader { geometry in
                let thumbWidth: CGFloat = 12 // Width of the thumb
                let trackWidth = geometry.size.width // Adjust the track width
                
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 0.35, green: 0.35, blue: 0.35))
                        .frame(height: 4)

                    // Filled track
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 0.11, green: 0.11, blue: 0.11))
                        .frame(width: CGFloat(sliderValue / 100) * (trackWidth - thumbWidth), height: 4) // Adjust the width

                    // Thumb
                    Circle()
                        .fill(Color(red: 0.11, green: 0.11, blue: 0.11))
                        .frame(width: thumbWidth, height: thumbWidth)
                        .offset(x: CGFloat(sliderValue / 100) * (trackWidth - 2*thumbWidth)) // Adjust the offset
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Update the sliderValue based on drag location
                                    let newValue = (value.location.x / (trackWidth - thumbWidth)) * 100
                                    sliderValue = min(max(newValue, 0), 100)
                                }
                        )
                }
                .padding(.horizontal, thumbWidth / 2) // Adjust padding to center the thumb
            }
            .frame(height: 20)
            
//            Text("Slider Value: \(sliderValue, specifier: "%.2f")")
//                .padding()
        }
//        .padding()
    }
}

#Preview {
    MusicSlider()
}
